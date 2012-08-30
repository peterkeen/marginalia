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
    @notes = current_or_guest_user.notes.tagged_with(@tag)

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end
end

