class RegistrationController < ApplicationController

  MARGINALIA_PRICE_CENTS = 1900

  DISCOUNT_CODES = {
    'TWENTYSEPT' => 1500
  }

  def new
    if user_signed_in? && current_user.stripe_id
      flash[:notice] = "You've already registered!"
      redirect_to "/notes"
      return
    end

    if params[:user_id] && User.find(params[:user_id])
      @user = User.find(params[:user_id])
      @disable_email_field = true
    elsif (guest_user && guest_user.has_guest_email?) || !guest_user
      @user = User.new
    else
      @disable_email_field = true
      @user = guest_user
    end

    session[:price] = MARGINALIA_PRICE_CENTS
    if params[:discount_code] && DISCOUNT_CODES[params[:discount_code]]
      session[:price] = DISCOUNT_CODES[params[:discount_code]]
     end

    log_event("Started Registration")
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = guest_user || User.new
    @user.assign_attributes(params[:user])

    respond_to do |format|
      if @user.valid?
        session[:new_user_params] = params[:user]
        log_event("Registered")
        format.html { redirect_to '/billing' }
      else
        format.html { render action: :new }
      end
    end
  end

  def new_billing
    if user_signed_in? && current_user.stripe_id
      flash[:notice] = "You've already registered!"
      redirect_to "/notes"
      return
    end

    @user = guest_user || User.new
    @user.assign_attributes(session[:new_user_params])

    log_event("Started Billing")
    respond_to do |format|
      format.html
    end
  end

  def charge_customer
    @user = guest_user || User.new
    @user.assign_attributes(session[:new_user_params])


    unless @user.stripe_id.nil?
      flash[:notice] = "You've already paid!"
      redirect_to '/notes'
    end

    begin
      customer = Stripe::Customer.create(
        :description => @user.email,
        :email => @user.email,
        :card => params['stripe_token']
      )
      @user.stripe_id = customer.id
      @user.save!

      charge = Stripe::Charge.create(
        :amount => session[:price],
        :currency => 'usd',
        :customer => customer.id
      )
    rescue Stripe::CardError => e
      @exception = e
      render action: :new_billing
      return
    end

    @user.is_guest = false
    @user.purchased_at = Time.now.utc
    @user.purchase_price = session[:price]
    @user.save!
    log_event("Charged Card", {:amount => session[:price]})

    sign_in(:user, @user)
    current_or_guest_user

    EventMailer.delay.welcome_to_marginalia(@user.id)

    respond_to do |format|
      format.html
    end

  end

end
