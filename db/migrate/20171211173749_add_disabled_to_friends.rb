class AddDisabledToBooks < ActiveRecord::Migration[5.1]
  def change
    add_column :books, :disabled, :boolean, :default => false
  end
end
