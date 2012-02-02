class NoteMailer < ActionMailer::Base
  def note_created(note)
    @note = note

    mail(
      :to => @note.from_address,
      :from => 'newnote@bugsplat-notes.mailgun.org',
      :reply_to => reply_to = "note-#{@note.unique_id}@bugsplat-notes.mailgun.org",
      :subject => "Re: #{@note.title}"
    )
  end

  def share(note, email)
    @note = note
    mail(
      :to => email,
      :from => @note.from_address,
      :reply_to => @note.from_address,
      :subject => "Shared note: #{@note.title}"
    )
  end
end
