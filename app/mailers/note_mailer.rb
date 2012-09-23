class NoteMailer < ActionMailer::Base
  def note_created(note_id)
    @note = Note.find(note_id)

    mail(
      :to => @note.from_address,
      :from => 'Marginalia <newnote@marginalia.io>',
      :reply_to => "note-#{@note.unique_id}@marginalia.io",
      :subject => "Re: Marginalia Note #{@note.title}"
    )
  end

  def share(share_id)
    @share = Share.find(share_id)
    @note = @share.note
    @user = @note.user
    mail(
      :to => @share.email,
      :from => @note.from_address,
      :reply_to => @note.from_address,
      :subject => "Marginalia Shared note: #{@note.title}"
    )
  end
end
