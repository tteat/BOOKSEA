class PagesController < ApplicationController
  def index
    @category = Category.first
    @most_traded = Book.active.with_exchanges_count :desc
    @tags_by_category = Tag.best_tags_by_category
    @recommendation = Book.where(id: rand(1..40)).first
  end

  def search
    # Validate tags
    @recommendation = Book.where(id: rand(1..40)).first
    @tags = Tag.where(id: (params[:tag] || params[:tags].try(:reject, &:empty?)))
    tag_ids = @tags.map(&:id)
    # Validate category
    @category = Category.find_by_id(params[:category])
    @book = Book.where(first_name: params[:book_name])
    if @category.blank?
    #if true
      #redirect_to @book
      @results = @book
    elsif tag_ids.blank?
      @results = Book.active.category(@category).latest
    else
      @results = Book.active.category(@category).with_tags(tag_ids, :desc)
    end
  end
end
