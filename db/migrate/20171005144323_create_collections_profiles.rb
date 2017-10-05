class CreateCollectionsProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :collections_profiles do |t|
      t.integer :run_id, null: false
      t.string :name, null: false
      t.float :total
      t.float :self
      t.float :wait
      t.float :child
      t.integer :calls
      t.float :percent_self

      t.timestamps
    end
    add_index :collections_profiles, :name
  end
end
