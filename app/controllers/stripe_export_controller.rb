class StripeExportController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_admin!

  def index
    @users = User.where('stripe_id is not null')
    p @users
    render :index, :layout => false
  end

  def ensure_admin!
    unless current_user.is_admin
      redirect_to '/notes'
    end
  end
  
end
