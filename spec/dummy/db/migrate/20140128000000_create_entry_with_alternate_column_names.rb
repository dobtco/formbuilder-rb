class CreateEntryWithAlternateColumnNames < ActiveRecord::Migration
  def change
    execute 'CREATE EXTENSION IF NOT EXISTS hstore'

    create_table :entry_with_alternate_column_names do |t|
      t.integer :form_id
      t.hstore :responses_alt, default: '', null: false
      t.text :responses_alt_text

      t.timestamps
    end
  end
end
