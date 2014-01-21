module Formbuilder
  class ResponseFieldFile < ResponseField

    after_initialize -> {
      @field_type = 'file'
      @search_type = 'file'
    }

    def render_input(value, opts = {})
      attachment = value && EntryAttachment.find(value)

      """
        <span class='existing-filename'>#{attachment.try(:upload).try(:file).try(:filename).try(:gsub, /\?.*$/, '')}</span>
        <input type='file' name='response_fields[#{self[:id]}]' id='response_fields_#{self[:id]}' />
      """
    end

    def render_entry(value, opts = {})
      attachment = value && EntryAttachment.where(id: value).first

      return unless attachment

      str = ""

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

      str
    end

    def audit_response(value, all_responses)
      return unless value && (record = Formbuilder::EntryAttachment.find(value))
      all_responses["#{self.id}_filename"] = record.read_attribute(:upload)
    end

    def sortable_value(value)
      value ? 1 : 0
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
        remove_entry_attachments(entry.old_responses[self.id.to_s]) # remove old attachments
        EntryAttachment.create(upload: raw_value).id
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