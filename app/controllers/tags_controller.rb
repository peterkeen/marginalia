class TagsController < ApplicationController
  def index

    @tags = current_or_guest_user.notes.tag_counts_on(:tags)

    respond_to do |format|
      format.html
      format.json { render json: @tags }
    end
  end

  def show
    p current_user
    @tag = params[:id]
    @tags = current_or_guest_user.notes.tag_counts_on(:tags)
    @notes = current_or_guest_user.notes.tagged_with(@tag)
    @projects = Project.find_all_by_user_id(current_or_guest_user.id, :order => "name")

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end
end

