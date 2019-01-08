class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update]
  before_action :authenticate_user!, except: [:show]
  before_action :require_owner, only: %i[edit update]

  # GET /books
  # GET /books.json
  def index
    @books = Book.of_user current_user
  end

  # GET /books/1
  # GET /books/1.json
  def show
    if @book.available? && @book.user != current_user && current_user
      @books_to_exchange = current_user.books.select { |f| f.available? }
    else
      @books_to_exchange = Book.none
    end
    @can_exchange = @books_to_exchange.any?
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit; end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params_create)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: '添加成功！' }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params_update)
        format.html { redirect_to @book, notice: '保存的信息！' }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:id])
  end

  def require_owner
    # should not happen, so an alert is not necessary
    redirect_to root_path if current_user != @book.user && !current_user.is_admin
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def book_params_create
    params.require(:book)
          .permit(:avatar, :first_name, :birthday, :is_male, :description, :category_id, tag_relations_attributes: [:tag_id])
          .merge(user_id: current_user.id)
  end

  def book_params_update
    params.require(:book).permit(:avatar, :description, :disabled)
  end
end
