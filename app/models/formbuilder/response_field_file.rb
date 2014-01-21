module Formbuilder
  class ResponseFieldFile < ResponseField

    after_initialize -> {
      @field_type = 'file'
      @search_type = 'file'
    }

    # @todo dropzone?
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

    def before_destroy(entry)
      entry.remove_entry_attachments(entry.responses[self.id.to_s])
    end

  end
end