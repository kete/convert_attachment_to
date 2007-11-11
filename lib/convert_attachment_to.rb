# ConvertAttachmentTo
#
# Walter McGinnis, 2007-11-09

require 'active_record'
require 'redcloth'

module Katipo #:nodoc:
  module Acts #:nodoc:
    module ConvertAttachmentTo
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # declare the class level helper methods which
      # will load the relevant instance methods
      # defined below when invoked
      module ClassMethods
        def convert_attachment_to(output_type, target_attribute)
          class_eval do
            cattr_accessor :acceptable_content_types
            @@acceptable_content_types = ['application/msword',
                                          'application/pdf',
                                          'text/html',
                                          'text/plain']

            cattr_accessor :configuration
            @@configuration = { :output_type = output_type,
              :target_attribute = target_attribute,
              :max_pdf_pages => 10 }

            # this needs to come after attachment_fu
            # in the order of things
            after_validation :do_conversion
          end

          include ConvertAttachmentTo::InstanceMethods
        end
      end

      module InstanceMethods
        # how it should work:
        # check that it's something we can deal with
        # like word doc or pdf
        # grab file
        # pick the translation method according to mime type and also specified output
        # put into attribute specified
        def do_conversion
          type_to_convert = self.content_type

          if @@acceptable_content_types.include?(type_to_convert)
            output = String.new

            if type_to_convert == 'text/plain'
              output = convert_from_text
            else
              output = self.send('convert_from_' + type_to_convert.split('/')[1])
            end

            write_attribute @@configuration[:target_attribute], output
          end
        end

        def convert_from_html
          case @@configuration[:output_type]
          when :html
            # read and discard the extra stuff we don't need
            raw_parts = File.read(self.full_filename).split('<body')
            # grab everything after the first >
            raw_parts[1].scan(/^[^>]*>/)
            raw_parts.delete_at(0)
            raw_parts = raw_parts.to_s.split('</body>')
            raw_parts[0]
          when :text
            # convert and discard the extra stuff we don't need
            # TODO: this has hardcoded debian/ubuntu config file path
            `lynx -dump file://#{self.full_filename}`
          end
        end

        def convert_from_text
          text = File.read(self.full_filename)
          case @@configuration[:output_type]
          when :html
            # read and discard the extra stuff we don't need
            raw = RedCloth.new text
            raw.to_html
          when :text
            text
          end
        end

        def convert_from_msword
          case @@configuration[:output_type]
          when :html
            # convert and discard the extra stuff we don't need
            raw_parts = `wvWare -c utf-8 --nographics -X #{self.full_filename}`.split('<doc>')
            # grab the the stuff after the <doc>, but before </doc>
            raw_parts = raw_parts[1].split('</doc>')
            raw_parts[0]
          when :text
            # convert and discard the extra stuff we don't need
            # TODO: this has hardcoded debian/ubuntu config file path
            `wvWare -c utf-8 --nographics -x /usr/share/wv/wvText.xml #{self.full_filename}`
          end
        end

        def convert_from_pdf
          case @@configuration[:output_type]
          when :html
            # convert and discard the extra stuff we don't need
            raw_parts = `pdftohtml -l #{@@configuration[:max_pdf_pages]} -i -noframes #{self.full_filename}`.split('<body')
            # grab everything after the first >
            raw_parts[1].scan(/^[^>]*>/)
            raw_parts.delete_at(0)
            raw_parts = raw_parts.to_s.split('</body>')
            raw_parts[0]
          when :text
            # convert and discard the extra stuff we don't need
            `pdftohtml -l #{@@configuration[:max_pdf_pages]} #{self.full_filename}`
          end
        end
      end
    end
  end
end

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it

ActiveRecord::Base.class_eval do
  include Katipo::Acts::ConvertAttachmentTo
end

