class Book < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :exchanges1, class_name: 'Exchange', foreign_key: 'book_initier_id'
  has_many :exchanges2, class_name: 'Exchange', foreign_key: 'book_receiver_id'
  has_many :tag_relations, inverse_of: :book
  has_many :tags, through: :tag_relations
  has_many :comments

  # Associates the attribute ":avatar" with a file attachment
  has_attached_file :avatar, styles: {
    original: '900x600#',
    thumb: '360x240#'
  }, convert_options: {
    original: '-quality 75 -strip',
    thumb: '-quality 75 -strip'
  }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  scope :active, -> { where disabled: false }
  scope :latest, -> { order updated_at: :desc }
  scope :category, ->(category) { where category: category }
  scope :search_book, ->(book) { where book: book }
  scope :of_user, ->(user) { where user: user }
  scope :of_book_receiver, ->(user) { where book_receiver_id: user }
  scope :with_tags, (lambda do |tag_ids, sort = nil|
    # require all tags to be present
    results = joins(:tag_relations).where('tag_relations.tag_id' => tag_ids)
                                   .group(:id)
                                   .having('COUNT(DISTINCT tag_relations.tag_id) = ?', tag_ids.size)
    # this sort is specific to this scope
    results = results.order("COUNT(*) #{sort}") if %i[asc desc].include? sort
    results
  end)
  scope :with_exchanges_count, (lambda do |sort = nil|
    results = select('books.*, COUNT(DISTINCT tag_relations.exchange_id) as exchanges_count')
                .joins(:tag_relations)
                .group(:id)
                .where(disabled: false)
    results = results.order("exchanges_count #{sort}") if %i[asc desc].include? sort
    results
  end)

  def exchanges(include_active = false)
    return Exchange.of_book(self) if include_active
    Exchange.of_book(self).active(false)
  end

  def tags_grouped
    groups = Hash.new(0)
    tags.each do |tag|
      groups[tag] += 1
    end
    groups
  end

  def tags_sorted(asc = false)
    tags_grouped.sort_by { |_, v| v }.tap { |o| o.reverse! unless asc }
  end

  def available?
    exchanges(include_active: true).where(is_active: true).none?
  end

  # VALIDATION

  validates :avatar, presence: true
  validates :first_name, length: { in: 2..50 }
  validates :birthday, presence: true
  validates :description, length: { in: 2..500 }
  validates :category_id, presence: true
  validates :user_id, presence: true

  validate :disable_while_exchanged
  validate :validate_age
  validate :check_tags_count, on: :create

  accepts_nested_attributes_for :tag_relations

  # PRIVATE METHODS

  private

  def disable_while_exchanged
      errors.add(:disabled, ': 在Exchange正在进行中无法禁用') if disabled && !available?
  end

  def validate_age
    if birthday.present? && (birthday > 13.years.ago || birthday < 90.years.ago)
      errors.add(:birthday)
    end
  end

  def check_tags_count
    # Using length as they are not saved in database yet
    l = tag_relations.length
    errors.add(:tags, ': 选择2到5个标签') if l < Tag::MIN_ASSOC || l > Tag::MAX_ASSOC
  end
end
