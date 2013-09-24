# This migration comes from formbuilder (originally 20130924185726)
class CreateFormbuilderForms < ActiveRecord::Migration
  def change
    create_table :formbuilder_forms do |t|
      t.integer :formable_id
      t.string :formable_type

      t.timestamps
    end
  end
end
