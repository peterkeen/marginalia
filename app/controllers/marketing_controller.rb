class MarketingController < ApplicationController

  layout 'marketing'

  protect_from_forgery
  before_filter :redirect_to_notes_if_logged_in

  def redirect_to_notes_if_logged_in
    redirect_to '/notes' if user_signed_in? || current_or_guest_user.notes.count > 0
  end

  def landing_page
    respond_to do |format|
      format.html do
        render params[:slug]
      end
    end
  end

  def index
    respond_to do |format|
      format.html do
        render :index
      end
    end
  end

end
