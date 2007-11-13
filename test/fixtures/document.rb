class Document < ActiveRecord::Base
  # we require attachment_fu setup
  has_attachment :storage => :file_system,
  :content_type => "['application/msword', 'application/pdf', 'text/html', 'text/plain']", :processor => :none

  # now our setup
  convert_attachment_to :html, :description
end
