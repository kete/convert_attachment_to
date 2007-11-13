require 'test/unit'
require File.join(File.dirname(__FILE__), 'test_helper')

# our test model
require File.join(File.dirname(__FILE__), 'fixtures/document')

class ConvertAttachmentToTest < Test::Unit::TestCase

  # test methods that do the conversions
  def test_convert_from_pdf_to_html
    to_html_doc = DocumentToHtml.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.pdf', 'application/pdf'))
    to_html_doc.save
    to_html_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/to_html.html')), to_html_doc.description, "convert_attachment_to plugin: pdf to html results in unexpected value."
  end

  def test_convert_from_pdf_to_text
    to_text_doc = DocumentToText.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.pdf', 'application/pdf'))
    to_text_doc.save
    to_text_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/to_text.txt')), to_text_doc.description, "convert_attachment_to plugin: pdf to text results in unexpected value."
  end

  def test_convert_from_msword_to_html
    to_html_doc = DocumentToHtml.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.doc', 'application/msword'))
    to_html_doc.save
    to_html_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/msword_to_html.html')), to_html_doc.description, "convert_attachment_to plugin: pdf to html results in unexpected value."
  end

  def test_convert_from_msword_to_text
    to_text_doc = DocumentToText.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.doc', 'application/msword'))
    to_text_doc.save
    to_text_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/msword_to_text.txt')), to_text_doc.description, "convert_attachment_to plugin: pdf to text results in unexpected value."
  end

  def test_convert_from_html_to_html
    to_html_doc = DocumentToHtml.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.html', 'text/html'))
    to_html_doc.save
    to_html_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/html_to_html.html')), to_html_doc.description, "convert_attachment_to plugin: html to html results in unexpected value."
  end

  def test_convert_from_html_to_text
    to_text_doc = DocumentToText.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.html', 'text/html'))
    to_text_doc.save
    to_text_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/to_text.txt')), to_text_doc.description, "convert_attachment_to plugin: html to text results in unexpected value."
  end

  def test_convert_from_text_to_html
    to_html_doc = DocumentToHtml.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    to_html_doc.save
    to_html_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/text_to_html.html')), to_html_doc.description, "convert_attachment_to plugin: text to html results in unexpected value."
  end

  def test_convert_from_text_to_text
    to_text_doc = DocumentToText.new(:title => 'test document',
                                     :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    to_text_doc.save
    to_text_doc.reload

    assert_equal File.read(File.join(File.dirname(__FILE__), 'fixtures/files/to_text.txt')), to_text_doc.description, "convert_attachment_to plugin: text to text results in unexpected value."
  end

  # test that uploaded file gets added to proper attribute in proper form
end
