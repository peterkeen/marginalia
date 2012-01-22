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
end
