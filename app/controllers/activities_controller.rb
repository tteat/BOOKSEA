class ActivitiesController < ApplicationController
  include ActivitiesHelper

  before_action :check_and_set_exchange, only: %i[get_finish post_finish get_rate post_rate]
  before_action :check_exchange_active, only: %i[get_finish post_finish]
  before_action :check_exchange_unactive_unrated, only: %i[get_rate post_rate]
  before_action :authenticate_user!

  def index
    # List exchanges of user
    books = current_user.books
    @exchanges = Exchange.of_book(books).latest
    @exchanges_active = []
    @exchanges_past = []
    @exchanges.each do |exchange|
      (exchange.is_active ? @exchanges_active : @exchanges_past) << exchange
    end
  end

  def new
    # Get books from GET params
    @book = Book.find(params[:book_id])
    @other = Book.find(params[:other_id])
    check_exchange_author && return
    @exchange = Exchange.new
  end

  def create
    # Get books from POST params
    @book = Book.find_by_id(params[:exchange][:book_initier_id])
    @other = Book.find_by_id(params[:exchange][:book_receiver_id])
    check_exchange_author && return
    @exchange = Exchange.new(exchange_params_create)
    if @exchange.save
      redirect_to exchanges_url, notice: "已经开始交换啦！"
    else
      render :new
    end
  end

  def get_finish
    render :finish
  end

  def post_finish
    if @exchange.update(is_active: false)
      redirect_to exchanges_get_rate_path(id: @exchange.id), notice: '这次交换已结束！'
    else
      render :finish
    end
  end

  def get_rate
    @book = distinct_books(@exchange).second
    render :rate
  end

  def post_rate
    @book = distinct_books(@exchange).second

    if @exchange.update(exchange_params_rate)
      redirect_to exchanges_path, notice: '已提交！'
    else
      render :rate
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def check_and_set_exchange
    @exchange = Exchange.find(params[:id])
    # should not happen, so an alert is not necessary
    return redirect_to root_path unless @exchange.books.count { |f| f.user == current_user } == 1
  end

  def check_exchange_active
    return redirect_to root_path unless @exchange.is_active
  end

  def check_exchange_unactive_unrated
    return redirect_to root_path if @exchange.is_active || @exchange.user_rated?(@current_user)
  end

  def check_exchange_author
    return redirect_to root_path unless @book.user == current_user &&
                                        @book.available? &&
                                        @other.user != current_user &&
                                        @other.available?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def exchange_params_create
    params.require(:exchange)
          .permit(:book_receiver_id, :book_initier_id)
          .merge(is_active: true)
  end

  def exchange_params_rate
    result = params.require(:exchange)
                   .permit(tag_relations_attributes: [:tag_id])
    result[:tag_relations_attributes].map { |t| t[:book_id] = @book.id }
    result
  end
end
