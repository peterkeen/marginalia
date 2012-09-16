class ProjectsController < ApplicationController

  include ApplicationHelper

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.find_all_by_user_id(current_or_guest_user.id, :order => "name")
    @tags = current_or_guest_user.notes.tag_counts_on(:tags)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @projects = Project.find_all_by_user_id(current_or_guest_user.id, :order => "name")
    @project = Project.where(:id => params[:id], :user_id => current_or_guest_user.id).first
    @notes = Note.where(:user_id => current_or_guest_user.id, :project_id => params[:id])
    @tags = current_or_guest_user.notes.tag_counts_on(:tags)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.where(:id => params[:id], :user_id => current_or_guest_user.id).first
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])
    @project.user_id = current_or_guest_user.id

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.where(:id => params[:id], :user_id => current_or_guest_user.id).first

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.where(:id => params[:id], :user_id => current_or_guest_user.id).first
    @project.destroy

    respond_to do |format|
      format.html { redirect_to notes_url }
      format.json { head :ok }
    end
  end
end
