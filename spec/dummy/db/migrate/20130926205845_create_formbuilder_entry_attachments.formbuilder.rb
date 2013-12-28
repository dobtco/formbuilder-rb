# This migration comes from formbuilder (originally 20130924185815)
class CreateFormbuilderEntryAttachments < ActiveRecord::Migration
  def change
    create_table :formbuilder_entry_attachments do |t|
      t.string :upload
      t.string :content_type
      t.integer :file_size

      t.timestamps
    end
  end
end
