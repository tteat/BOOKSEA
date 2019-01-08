class ChangeBooksColumnsOfExchange < ActiveRecord::Migration[5.1]
  def change
    rename_column :exchanges, :book1_id, :book_initier_id
    rename_column :exchanges, :book2_id, :book_receiver_id
  end
end
