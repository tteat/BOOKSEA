class Activity < ApplicationRecord
  belongs_to :user

  # VALIDATION

  validates :title, presence: true

  scope :of_user, ->(user) { where user: user }

end
