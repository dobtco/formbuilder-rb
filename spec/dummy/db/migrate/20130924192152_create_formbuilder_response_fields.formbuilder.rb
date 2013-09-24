# This migration comes from formbuilder (originally 20130924185814)
class CreateFormbuilderResponseFields < ActiveRecord::Migration
  def change
    create_table :formbuilder_response_fields do |t|
      t.integer :form_id
      t.text :label
      t.string :type
      t.text :field_options
      t.integer :sort_order
      t.boolean :required, default: false
      t.boolean :blind, default: false
      t.boolean :admin_only, default: false

      t.timestamps
    end
  end
end
