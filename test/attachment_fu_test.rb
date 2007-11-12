require File.join(File.dirname(__FILE__), 'abstract_unit')

# simply test whether acts_as_versioned is installed in this app
class AttachmentFuTest < Test::Unit::TestCase
  def test_has_acts_as_versioned
    assert_equal true, included_modules.include?(Technoweenie::AttachmentFu::ActMethods), "This app needs to have the attachment_fu plugin installed to work with the convert_attachment_to plugin."
  end
end

