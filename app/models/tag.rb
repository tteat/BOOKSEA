class Tag < ApplicationRecord
  MIN_ASSOC = 2
  MAX_ASSOC = 5

  has_many :tag_relations
  has_many :books, through: :tag_relations

  def label(test)
    return test.is_male ? label_male : label_female if test.is_a? Book
    test ? label_male : label_female
  end

  def books_grouped
    groups = Hash.new(0)
    books.each do |book|
      groups[book] += 1
    end
    groups
  end

  def books_sorted(asc = false)
    books_grouped.sort_by { |_, v| v }.tap { |o| o.reverse! unless asc }
  end

  def self.best_tags_by_category
    # NOTE 1: can't scope this method as it has some logic code associated, and is highly specific
    # NOTE 2: here we are quering, then filtering results by ourselves...
    tags_by_category = Tag.select('tags.*, '\
                              'categories.id as category_id, '\
                              'categories.name as category_name, '\
                              'COUNT(DISTINCT books.id) as count')
                      .joins(:tag_relations)
                      .joins(:books)
                      .joins('INNER JOIN categories ON categories.id = books.category_id')
                      .where('books.disabled' => false)
                      .group('categories.id, tags.id')
    hash = Hash.new(0)
    tags_by_category.each do |tag|
      hash[tag.category_id] = [tag.count, tag] if tag.count > hash[tag.category_id][0]
    end
    hash.values.sort_by { |entry| entry[0] }.reverse.map { |entry| entry[1] }

    # ... as the following query works in SQLite, but not in PostgreSQL
    # Tag.select('id, label_male, category_name, category_id, MAX(books_count) as count')
    #                    .from(
    #                      Tag.select(
    #                        'tags.*, '\
    #                        'categories.id as category_id, '\
    #                        'categories.name as category_name, '\
    #                        'COUNT(DISTINCT books.id) as books_count'
    #                      )
    #                      .joins(:tag_relations)
    #                      .joins(:books)
    #                      .joins('INNER JOIN categories ON categories.id = books.category_id')
    #                      .where('books.disabled' => false)
    #                      .group('categories.id, tags.id')
    #                   )
    #                   .group('category_id')
    #                   .order('count DESC')
  end

  # VALIDATION

  validates :label_male, presence: true
  validates :label_female, presence: true
end
