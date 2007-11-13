require 'test/unit'
require File.join(File.dirname(__FILE__), 'abstract_unit')

# our test model
require File.join(File.dirname(__FILE__), 'fixtures/document')

class ConvertAttachmentToTest < Test::Unit::TestCase
  def setup

  end

  # test set up method

  # test methods that do the conversions
  def test_convert_from_pdf_html
  end

  # test that uploaded file gets added to proper attribute in proper form
end
