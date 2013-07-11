class RegistrationController < ApplicationController

  def new
    if user_signed_in? && current_user.stripe_id
      flash[:notice] = "You've already registered!"
      redirect_to "/notes"
      return
    end

    session[:plan_id] = params[:p]

    if params[:user_id] && User.find(params[:user_id])
      @user = User.find(params[:user_id])
      sign_in @user
      @disable_email_field = true
    elsif (user_signed_in? && current_user.stripe_id.nil?)
      @disable_email_field = true
      @user = current_user
    else (guest_user && guest_user.has_guest_email?) || !guest_user
      @user = User.new
    end

    log_event("Started Registration")
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = current_user || guest_user || User.new
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
        :card => params['stripe_token'],
        :plan => Plan.find(session[:plan_id]).slug
      )

      @user.plan_id = session[:plan_id]
      @user.stripe_id = customer.id
      @user.save!

    rescue Stripe::CardError => e
      @exception = e
      render action: :new_billing
      return
    end

    @user.is_guest = false
    @user.purchased_at = Time.now.utc
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
