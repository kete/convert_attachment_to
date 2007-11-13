require 'test/unit'
require File.join(File.dirname(__FILE__), 'test_helper')

# our test model
require File.join(File.dirname(__FILE__), 'fixtures/document')

class ConvertAttachmentToTest < Test::Unit::TestCase

  # test methods that do the conversions
  def test_convert_from_pdf
    to_html_doc = DocumentToHtml.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.pdf', 'application/pdf'))
    to_html_doc.save
    to_html_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/to_html.html')), to_html_doc.description, "convert_attachment_to plugin: pdf to html results in unexpected value."

  end

  # test that uploaded file gets added to proper attribute in proper form
end
