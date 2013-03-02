class AddPendingToImages < ActiveRecord::Migration
  def change
    add_column :images, :pending, :boolean
  end
end
