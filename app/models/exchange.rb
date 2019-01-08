class Exchange < ApplicationRecord
  include ExchangesHelper

  belongs_to :book_initier, class_name: 'Book', foreign_key: 'book_initier_id'
  belongs_to :book_receiver, class_name: 'Book', foreign_key: 'book_receiver_id'
  has_many :tag_relations, inverse_of: :exchange

  scope :latest, -> { order updated_at: :desc }
  scope :active, ->(active = true) { where is_active: active }
  scope :of_book, (lambda do |book|
    where(book_initier_id: book)
      .or(Exchange.where(book_receiver_id: book))
  end)

  def books
    [book_initier, book_receiver]
  end

  def user_rated?(user)
    book_rated? distinct_books(self, user).second
  end

  def book_rated?(book)
    tag_relations.where(book: book).any?
  end

  # AUTO-UPDATE FIELDS

  before_create :set_start_date
  before_save :set_end_date

  # VALIDATION

  validates :book_initier_id, presence: true
  validates :book_receiver_id, presence: true

  validate :check_different
  validate :check_owner
  validate :check_available, on: :create
  validate :check_unavailable, on: :update
  validate :check_tags_count, on: :update

  accepts_nested_attributes_for :tag_relations

  # PRIVATE METHODS

  private

  def set_start_date
    self.start_date = Time.now unless start_date
  end

  def set_end_date
    self.end_date = Time.now unless is_active? || end_date
  end

  def check_different
    errors.add(:base, "不能交朋友反对自己") unless book_initier.id != book_receiver.id
  end

  def check_available
    errors.add(:base, "其中一位朋友不在") unless book_initier.available? && book_receiver.available?
  end

  def check_unavailable
    errors.add(:base, "交换已经完成") if is_active
  end

  def check_owner
    errors.add(:base, "无法交易同一用户的两个朋友") unless book_initier.user.id != book_receiver.user.id
  end

  def check_tags_count
    # Using length as they are not saved in database yet
    # length - count = how many tags in total - how many in database = how many are added
    l = tag_relations.length - tag_relations.count
    errors.add(:tags, ': 选择2到5个标签') if l != 0 && (l < Tag::MIN_ASSOC || l > Tag::MAX_ASSOC)
  end
end
