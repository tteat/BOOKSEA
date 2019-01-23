class ActivitiesController < ApplicationController
  include ActivitiesHelper

  before_action :check_and_set_activity, only: %i[get_finish post_finish get_rate post_rate]
  before_action :check_activity_active, only: %i[get_finish post_finish]
  before_action :check_activity_unactive_unrated, only: %i[get_rate post_rate]
  before_action :set_activity, only: %i[show edit update]
  before_action :authenticate_user!

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def index
    # List activities
    @activities = Activity.of_user current_user
    @activities_active = []
    @activities_past = []
    @activities.each do |activity|
      (activity.ended_at > 2019-01-13 ? @activities_active : @activities_past) << activity

    end
  end

  def show
    if current_user
      @books_to_activity = current_user.books.select { |f| f.available? }
    else
      @books_to_activity = Book.none
    end
    @can_activity = @books_to_activity.any?
  end

  def new
    # Get books from GET params
    # @book = Book.find(params[:book_id])
    # @other = Book.find(params[:other_id])
    # check_exchange_author && return
    # @exchange = Exchange.new
    @activity = Activity.new
  end

  def create

    @activity = Activity.new(activity_params_create)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: '添加成功！' }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # def join
  #
  #   @activity = Activity.new(activity_params_join)
  #
  #   respond_to do |format|
  #     if @activity.save
  #       format.html { redirect_to @activity, notice: '加入成功！' }
  #       format.json { render :show, status: :created, location: @activity }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @activity.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # def activity_params_join
  #   params.require(:activity)
  #       .permit(:title, :created_at,:ended_at, :place, :content)
  #       .merge(user_id: current_user.id)
  # end

  def get_finish
    render :finish
  end

  def post_finish
    if @activity.update(is_active: false)
      redirect_to activities_get_rate_path(id: @activity.id), notice: '这次活动已结束！'
    else
      render :finish
    end
  end

  def get_rate
    @book = distinct_books(@activity).second
    render :rate
  end

  def post_rate
    @book = distinct_books(@activity).second

    if @activity.update(activity_params_rate)
      redirect_to activities_path, notice: '已提交！'
    else
      render :rate
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def check_and_set_activity
    @activity = Activity.find(params[:id])
    # should not happen, so an alert is not necessary
    return redirect_to root_path unless @activity.books.count { |f| f.user == current_user } == 1
  end

  def check_activity_active
    return redirect_to root_path unless @activity.is_active
  end

  def check_activity_unactive_unrated
    return redirect_to root_path if @activity.is_active || @activity.user_rated?(@current_user)
  end

  def check_activity_author
    return redirect_to root_path unless @book.user == current_user &&
                                        @book.available? &&
                                        @other.user != current_user &&
                                        @other.available?
  end


  def activity_params_create
    params.require(:activity)
        .permit(:title, :created_at,:ended_at, :place, :content)
        .merge(user_id: current_user.id)
  end

  def activity_params_rate
    result = params.require(:activity)
                   .permit(tag_relations_attributes: [:tag_id])
    result[:tag_relations_attributes].map { |t| t[:book_id] = @book.id }
    result
  end
end
