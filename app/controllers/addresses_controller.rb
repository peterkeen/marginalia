class AddressesController < ApplicationController

  before_filter :authenticate_user!
  
  def index
    @addresses = UserEmail.where(:user_id => current_user.id).all

    respond_to do |format|
      format.html
      format.json { render json: @addresses }
    end
  end

  def new
    @address = UserEmail.new(:user_id => current_user.id)

    respond_to do |format|
      format.html
      format.json { render json: @note }
    end
  end

  def edit
    @address = UserEmail.where(:id => params[:id], :user_id => current_user.id).first
  end

  def create
    @address = UserEmail.new(params[:user_email])
    @address.user_id = current_user.id

    respond_to do |format|
      if @address.save
        format.html { redirect_to edit_user_registration_path, notice: 'Address successfully added.' }
        format.json { render json: @address, status: :created, location: @address }
      else
        format.html { render action: 'new' }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @address = UserEmail.where(:id => params[:id], :user_id => current_user.id).first

    respond_to do |format|
      if @address.update_attributes(params[:user_email])
        format.html { redirect_to :index, notice: 'Address successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @address = UserEmail.where(:id => params[:id], :user_id => current_user.id).first
    @address.destroy

    respond_to do |format|
      format.html { redirect_to addresses_url }
      format.json { head :ok }
    end
  end

end
