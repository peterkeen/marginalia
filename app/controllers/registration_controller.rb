class RegistrationController < ApplicationController

  MARGINALIA_PRICE_CENTS = 1900

  def new
    @user = User.new
    track! :register_start
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        track! :register_finish
        session[:new_user_id] = @user.id
        format.html { redirect_to '/billing' }
      else
        format.html { render action: :new }
      end
    end
  end

  def new_billing
    @user = User.find(session[:new_user_id])
    track! :billing_start
    respond_to do |format|
      format.html
    end
  end

  def charge_customer
    @user = User.find(session[:new_user_id])

    begin
      customer = Stripe::Customer.create(
        :description => @user.email,
        :email => @user.email,
        :card => params['stripe_token']
      )
      @user.stripe_id = customer.id
      @user.save!

      charge = Stripe::Charge.create(
        :amount => MARGINALIA_PRICE_CENTS,
        :currency => 'usd',
        :customer => customer.id
      )
    rescue Stripe::CardError => e
      @exception = e
      render action: :new_billing
      return
    end

    @user.purchased_at = Time.now.utc
    @user.save!
    track! :billing_finish

    sign_in(:user, @user)
    current_or_guest_user

    EventMailer.delay.welcome_to_marginalia(@user.id)

    respond_to do |format|
      format.html
    end

  end

end
