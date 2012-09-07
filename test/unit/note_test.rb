require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end


  test "extracts tags" do
    note = Note.new(:body => "some #tags", :title => "foo", :user_id => 1)
    note.save

    assert_equal note.tag_list, ['tags']
  end
end
