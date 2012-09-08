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

  test "renders labels" do
    note = Note.new(:body => "{{Label(foo)}}", :title => "foo", :user_id => 1)
    assert_equal "<p><span class='label'>foo</span></p>", note.rendered_body
  end

  test "renders labels with classes" do
    note = Note.new(:body => "{{Label(foo,important)}}", :title => "foo", :user_id => 1)
    assert_equal "<p><span class='label label-important'>foo</span></p>", note.rendered_body
  end
    
end
