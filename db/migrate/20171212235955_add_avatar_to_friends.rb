class AddAvatarTobooks < ActiveRecord::Migration[5.1]
  def self.up
    add_attachment :books, :avatar
  end

  def self.down
    remove_attachment :books, :avatar
  end
end
