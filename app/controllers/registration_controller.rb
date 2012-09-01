class RegistrationController < ApplicationController

  MARGINALIA_PRICE_CENTS = 1900

  def new
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { redirect_to '/billing' }
      else
        format.html { render action: :new }
      end
    end
  end

  def new_billing
    @user = User.find(session[:user_id])
    respond_to do |format|
      format.html
    end
  end

  def charge_customer
    @user = User.find(session[:user_id])

    begin
      customer = Stripe::Customer.create(
        :description => @user.email,
        :email => @user.email,
        :card => params['stripe_token']
      )
      @user.stripe_customer_id = customer.id
      @user.save!

      charge = Stripe::Charge.create(
        :amount => amount,
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

    EventMailer.welcome_to_marginalia(@user.id).deliver

    respond_to do |format|
      format.html
    end

  end

end
