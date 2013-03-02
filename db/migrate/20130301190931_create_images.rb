class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
      t.string :path
      t.string :thumbnail
      t.string :description
      t.integer :size

      t.timestamps
    end
  end
end
