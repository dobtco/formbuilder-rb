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

      get_attachments(value).each do |attachment|
        return_str += "".tap do |str|
          str += """
            <a href='#{attachment.upload.url}' target='_blank'>
          """

          if attachment.upload.send(:active_versions).include?(:thumb)
            str += """
              <img src='#{attachment.upload.thumb.url}' /><br />
            """
          end

          str +="""
              #{attachment.upload.try(:file).try(:filename).try(:gsub, /\?.*$/, '')}
            </a>
          """
        end
      end

      return_str
    end

    def audit_response(value, all_responses)
      return unless value
      all_responses["#{self.id}_filename"] = get_attachments(value).try(:first).try(:upload).try(:raw_filename)
    end

    def sortable_value(value)
      value.present? ? 1 : 0
    end

    def before_response_destroyed(entry)
      remove_entry_attachments(entry.responses[self.id.to_s])
    end

    def transform_raw_value(raw_value, entry, opts = {})
      # if the file is already uploaded and we're not uploading another, be sure to keep it
      # @todo currently no way of removing a file
      if raw_value.blank?
        entry.old_responses.try(:[], self.id.to_s)
      else
        remove_entry_attachments(entry.responses.try(:[], self.id.to_s)) # remove old attachments
        remove_entry_attachments(entry.old_responses.try(:[], self.id.to_s)) # remove old attachments

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