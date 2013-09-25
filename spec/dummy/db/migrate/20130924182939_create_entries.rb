class CreateEntries < ActiveRecord::Migration
  def change
    execute 'CREATE EXTENSION IF NOT EXISTS hstore'

    create_table :entries do |t|
      t.integer :form_id
      t.datetime :submitted_at
      t.hstore :responses
      t.text :responses_text

      t.timestamps
    end
  end
end
