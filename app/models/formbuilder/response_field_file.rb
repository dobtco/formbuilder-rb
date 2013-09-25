module Formbuilder
  class ResponseFieldFile < ResponseField

    after_initialize -> {
      @field_type = 'file'
    }

    # @todo dropzone?
    def render_input(value, opts = {})
      attachment = value && EntryAttachment.find(value)

      """
        <span class='existing-filename'>#{attachment.try(:upload).try(:file).try(:filename).try(:gsub, /\?.*$/, '')}</span>
        <input type='file' name='response_fields[#{self[:id]}]' />
      """
    end

    def render_entry(value, opts = {})
      attachment = EntryAttachment.find(value)

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

  end
end