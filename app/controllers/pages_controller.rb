class PagesController < ApplicationController
  def index
    @category = Category.first
    @most_traded = Book.active.with_exchanges_count :desc
    @tags_by_category = Tag.best_tags_by_category
  end

  def search
    # Validate tags
    @tags = Tag.where(id: (params[:tag] || params[:tags].try(:reject, &:empty?)))
    tag_ids = @tags.map(&:id)
    # Validate category
    @category = Category.find_by_id(params[:category])
    if @category.blank?
      redirect_to root_path
    elsif tag_ids.blank?
      @results = Book.active.category(@category).latest
    else
      @results = Book.active.category(@category).with_tags(tag_ids, :desc)
    end
  end
end
