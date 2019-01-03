class Category < ApplicationRecord
  has_many :friends

  # VALIDATION

  validates :name, presence: true

end
