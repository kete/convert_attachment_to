# ConvertAttachmentTo
#
# Walter McGinnis, 2007-11-09

require 'active_record'
require 'redcloth'

module Katipo #:nodoc:
  module Acts #:nodoc:
    module ConvertAttachmentTo
      @@acceptable_content_types = ['application/msword',
                                    'application/pdf',
                                    'text/html',
                                    'text/plain']
      @@tempfile_path = File.join(RAILS_ROOT, 'tmp', 'convert_attachment_to')
      mattr_reader :acceptable_content_types, :tempfile_path

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # declare the class level helper methods which
      # will load the relevant instance methods
      # defined below when invoked
      module ClassMethods
        def convert_attachment_to(output_type, target_attribute)
          class_eval do
            include Katipo::Acts::ConvertAttachmentTo::InstanceMethods

            class_inheritable_accessor :configuration
            self.configuration = { :output_type => output_type,
              :target_attribute => target_attribute,
              :max_pdf_pages => 10 }

            # this needs to come after attachment_fu
            # in the order of things
            after_validation :do_conversion
          end
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
          if Katipo::Acts::ConvertAttachmentTo.acceptable_content_types.include?(type_to_convert)
            output = String.new

            if type_to_convert == 'text/plain'
              output = convert_from_text
            else
              output = self.send('convert_from_' + type_to_convert.split('/')[1])
            end

            write_attribute configuration[:target_attribute], output
          end
        end

        def convert_from_html
          case configuration[:output_type]
          when :html
            # read and discard the extra stuff we don't need
            # TODO: make this split case insensitive
            raw_parts = File.read(self.full_filename).split('<body')
            # pop off first line, which has remains of body tag
            raw_body_parts = raw_parts[1].split(/\n/)
            raw_body_parts.delete_at(0)
            raw_body_parts = raw_body_parts.join("\n").to_s.split('</body>')
            raw_body_parts[0].strip
          when :text
            # convert and discard the extra stuff we don't need
            # TODO: this has hardcoded debian/ubuntu config file path
            `lynx -dump file://#{self.full_filename}`.strip
          end
        end

        def convert_from_text
          text = File.read(self.full_filename)
          case configuration[:output_type]
          when :html
            # read and discard the extra stuff we don't need
            raw = RedCloth.new text
            raw.to_html.strip
          when :text
            text.strip
          end
        end

        def convert_from_msword
          case configuration[:output_type]
          when :html
            # convert and discard the extra stuff we don't need
            raw_parts = `wvWare -c utf-8 --nographics -X #{self.full_filename}`.split('<doc>')
            # grab the the stuff after the <doc>, but before </doc>
            raw_parts = raw_parts[1].split('</doc>')
            raw_parts[0].strip
          when :text
            # convert and discard the extra stuff we don't need
            # TODO: this has hardcoded debian/ubuntu config file path
            `wvWare -c utf-8 --nographics -x /usr/share/wv/wvText.xml #{self.full_filename}`.strip
          end
        end

        def convert_from_pdf
          case configuration[:output_type]
          when :html
            # convert and discard the extra stuff we don't need
            raw_parts = `pdftohtml -l #{configuration[:max_pdf_pages]} -i -noframes -stdout #{self.full_filename}`.split('<BODY')
            # pop off first line (remains of body tag)
            raw_body_parts = raw_parts[1].split(/\n/)
            raw_body_parts.delete_at(0)
            raw_body_parts = raw_body_parts.join("\n").to_s.split('</BODY>')
            raw_body_parts[0].strip
          when :text
            # convert and discard the extra stuff we don't need
            Dir.mkdir Katipo::Acts::ConvertAttachmentTo.tempfile_path unless File.exists?(Katipo::Acts::ConvertAttachmentTo.tempfile_path)

            existing_filename = self.thumbnail_name_for(nil)
            new_filename = File.basename(existing_filename, File.extname(existing_filename)) + ".txt"
            full_new_filename = File.join(Katipo::Acts::ConvertAttachmentTo.tempfile_path, new_filename)
            `pdftotext -l #{configuration[:max_pdf_pages]} -nopgbrk #{self.full_filename} #{full_new_filename}`
            File.read(full_new_filename).strip
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

