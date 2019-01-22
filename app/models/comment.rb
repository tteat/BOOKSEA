class Comment < ApplicationRecord
  belongs_to :book

  # VALIDATION

  validates :content, presence: true

end
