class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.integer :formable_id
      t.string :formable_type

      t.timestamps
    end
  end
end
