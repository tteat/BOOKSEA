class CreateExchanges < ActiveRecord::Migration[5.1]
  def change
    create_table :exchanges do |t|
      t.boolean :is_active
      t.references :book1, foreign_key: true
      t.references :book2, foreign_key: true

      t.timestamps
    end
  end
end
