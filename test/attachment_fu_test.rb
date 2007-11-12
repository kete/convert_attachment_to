require File.join(File.dirname(__FILE__), 'abstract_unit')

# simply test whether acts_as_versioned is installed in this app
class AttachmentFuTest < Test::Unit::TestCase
  def test_has_attachment_fu
    assert_equal true, require 'technoweenie/attachment_fu'
  end
end

