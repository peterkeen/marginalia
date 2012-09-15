class MarketingController < ApplicationController

  layout 'marketing'

  protect_from_forgery
  before_filter :redirect_to_notes_if_logged_in, :only => :index

  def redirect_to_notes_if_logged_in
    redirect_to '/notes' if user_signed_in?
  end

  def landing_page
    respond_to do |format|
      params[:layout] ||= "application"
      format.html do
        begin
          @supress_nav = true
          @note = Note.where(:slug => params[:slug], :user_id => User.find_by_email('admin@marginalia.io').id).first
          if @note
            render :landing_page, :layout => params[:layout]
          else
            render params[:slug], :layout => params[:layout]
          end
        rescue ActionView::MissingTemplate
          raise ActionController::RoutingError.new("Not Found")
        end
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
