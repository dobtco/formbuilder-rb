module Formbuilder
  class ResponseFieldFile < ResponseField

    # Notes:
    #   I'm modifying this class to accept multiple attachments,
    #   even though the frontend will only accept one (for now).

    after_initialize -> {
      @field_type = 'file'
      @search_type = 'file'
    }

    def get_attachments(value)
      if value.blank?
        []
      else
        EntryAttachment.where('id IN (?)', value.split(','))
      end
    end

    def render_input(value, opts = {})
      """
        <span class='existing-filename'>#{get_attachments(value).first.try(:upload).try(:raw_filename)}</span>
        <input type='file' name='response_fields[#{self[:id]}][]' id='response_fields_#{self[:id]}' />
      """
    end

    def render_entry(value, opts = {})
      return_str = ""

      return_str << get_attachments(value).map do |attachment|
        String.new.tap do |str|
          str << """
            <a href='#{attachment.upload.url}' target='_blank'>
          """

          if attachment.upload.send(:active_versions).include?(:thumb)
            str << """
              <img src='#{attachment.upload.thumb.url}' /><br />
            """
          end

          str << """
              #{attachment.upload.try(:raw_filename)}
            </a>
          """
        end
      end.join('<br /><br />').squish

      return_str
    end

    def render_entry_text(value, opts = {})
      get_attachments(value).map { |attachment|
        attachment.upload.url
      }.join(', ')
    end

    def audit_response(value, all_responses)
      return unless value
      all_responses["#{self.id}_filename"] = get_attachments(value).try(:first).try(:upload).try(:raw_filename)
    end

    def sortable_value(value)
      value.present? ? 1 : 0
    end

    def before_response_destroyed(entry)
      remove_entry_attachments(entry.get_responses[self.id.to_s])
    end

    def transform_raw_value(raw_value, entry, opts = {})
      raw_value = [raw_value] unless raw_value.is_a?(Array)
      raw_value = raw_value.reject { |x| x.blank? }

      # if the file is already uploaded and we're not uploading another, be sure to keep it
      # @todo currently no way of removing a file
      if raw_value.empty?
        entry.responses_column_was.try(:[], self.id.to_s)
      elsif raw_value == 'deleted'
        remove_entry_attachments(entry.get_responses.try(:[], self.id.to_s)) # remove old attachments
        remove_entry_attachments(entry.responses_column_was.try(:[], self.id.to_s)) # remove old attachments
      else
        remove_entry_attachments(entry.get_responses.try(:[], self.id.to_s)) # remove old attachments
        remove_entry_attachments(entry.responses_column_was.try(:[], self.id.to_s)) # remove old attachments

        raw_value.map do |file|
          EntryAttachment.create(upload: file).id
        end.join(',')
      end
    end

    def remove_entry_attachments(entry_attachment_ids)
      return unless entry_attachment_ids.present?

      entry_attachment_ids.to_s.split(',').each do |x|
        EntryAttachment.find_by(id: x).try(:destroy)
      end
    end

  end
end