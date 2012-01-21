Note Tracker
------------

Email is the only way that my brain lets me write down notes. I've tried lots of other systems but none of them have really stuck. This project is intended as a systematic way to keep track of notes and refinements while still exploiting the email-centric workflow that I know and love.

Email Workflow:
- send an email to newnotes@zrail.net from an authenticated address. The email will be interpreted as a markdown document.
- the system will reply with a message that says "new note created" and a unique reply-to address
- replying to the "created" message will append to the original markdown document

Web Workflow:
- login to zrail.net
- see a list of notes and a button to create a new one
- viewing an note gives the markdown-rendered version
- each note also has a version history saved using paper_trail
- editing an note creates a new version (appending via email also creates a new version)

REST API Workflow:
- basic auth
- GET /notes returns a list of notes
- POST /notes creates a new one
- GET /notes/id returns that note
- PUT /notes/id updates that note
- GET /notes/id/versions returns all of the versions for that note

#### Models
- User `(devise user)`
- UserAddress `(id integer, user_id integer, address text)`
- Note `(id integer, user_id integer, title text, body text, from_address text)`
- Version `(paper_trail)`
- (`acts_as_taggable_on` tables) 

You know, this is pretty much a wiki with the email functionality built-in.

Simple Redcarpet renderer extension

    class HTMLWithHashtags < Redcarpet::Renderer::HTML
      attr_reader :tags
      def preprocess(full_document)
        @tags = Set.new
        full_document.gsub(/\b#(\w+)\b/) do |match|
          @tags << $1
          "[#{$1}](/tags/#{$1})"
        end
      end
    end
