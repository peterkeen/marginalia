class StripeExportController < ApplicationController

  def index
    @users = User.where('stripe_id is not null')
    render :index, :layout => false
  end
  
end
