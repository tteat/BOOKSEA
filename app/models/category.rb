class Category < ApplicationRecord
  has_many :books

  # VALIDATION

  validates :name, presence: true

end
