class Document < ActiveRecord::Base
  # we require attachment_fu setup
  has_attachment :storage => :file_system,
  :content_type => "['application/msword', 'application/pdf', 'text/html', 'text/plain']", :processor => :none
end

class DocumentToHtml < Document
  # now our setup
  convert_attachment_to :text, :description
end

class DocumentToText < Document
  # now our setup
  convert_attachment_to :text, :description
end
