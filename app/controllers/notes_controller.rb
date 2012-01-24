class NotesController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:create_from_mailgun, :update_from_mailgun]

  # GET /notes
  # GET /notes.json
  def index
    @notes = Note.find_all_by_user_id(current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notes }
    end
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
    @note = Note.where(:id => params[:id], :user_id => current_user.id).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @note }
    end
  end

  # GET /notes/new
  # GET /notes/new.json
  def new
    @note = Note.new(params[:note])
    @note.user_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @note }
    end
  end

  # GET /notes/1/edit
  def edit
    @note = Note.where(:id => params[:id], :user_id => current_user.id).first
  end

  # POST /notes
  # POST /notes.json
  def create
    @note = Note.new(params[:note])
    @note.user_id = current_user.id

    respond_to do |format|
      if @note.save
        NoteMailer.note_created(@note).deliver
        format.html { redirect_to @note, notice: 'Note was successfully created.' }
        format.json { render json: @note, status: :created, location: @note }
      else
        format.html { render action: "new" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.json
  def update
    @note = Note.where(:id => params[:id], :user_id => current_user.id).first

    respond_to do |format|
      if @note.update_attributes(params[:note])
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @note = Note.where(:id => params[:id], :user_id => current_user.id).first
    @note.destroy

    respond_to do |format|
      format.html { redirect_to notes_url }
      format.json { head :ok }
    end
  end

  def create_from_mailgun
    @note = Note.new

    from_address = parse_address
    user = User.find(UserEmail.find_by_email(from_address).user_id)
    if user.nil?
      render :status => :ok, :text => 'Rejected'
      return
    end

    @note.user_id = user.id

    if validate_mailgun_signature
      @note.title = params['subject']
      @note.body = params['stripped-text']
      @note.from_address = parse_address
    else
      render :status => :unprocessable_entity, :text => 'Invalid Signature'
      return
    end

    if @note.save
      NoteMailer.note_created(@note).deliver
      render :status => :ok, :text => 'OK'
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def update_from_mailgun
    if validate_mailgun_signature
      unique_id = parse_unique_from_address
      @note = Note.find_by_unique_id(unique_id)

      from_address = parse_address
      user = User.find(UserEmail.find_by_email(from_address).user_id)
      if user.nil?
        render :status => :ok, :text => 'Rejected'
        return
      end

      if @note.nil?
        raise ActionController::RoutingError.new('Not Found')
      end
      @note.body += "\n\n#{params['stripped-text']}"
      if @note.save
        render :status => :ok, :text => 'OK'
      else
        render json: @note.errors, status: :unprocessable_entity
      end
    else
      render :status => :unprocessable_entity, :text => 'Invalid Signature'      
    end
  end

  def parse_unique_from_address
    params['recipient'].split(/@/)[0].gsub('note-', '')
  end

  def parse_address
    params['from'].scan(/<(.+)>/)[0][0] rescue params['from']
  end

  def validate_mailgun_signature
    signature = params['signature']
    return false if signature.nil?

    test_signature = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest::Digest.new('sha256'),
      ENV['MAILGUN_API_KEY'],
      '%s%s' % [params['timestamp'], params['token']]
    )

    return signature == test_signature
  end

  def search
    @notes = Note.search(params['q']).where(:user_id => current_user.id)
    @query = params['q']

    respond_to do |format|
      format.html # search.html.erb
      format.json { render json: @notes }
    end
  end
end
