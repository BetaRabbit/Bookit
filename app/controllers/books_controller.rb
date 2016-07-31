class BooksController < ApplicationController
  require 'api/amazon'

  before_action :set_book, only: [:show, :update, :destroy]

  # GET /books
  def index
    @books = Book.all

    render json: @books
  end

  # GET /books/1
  def show
    render json: @book
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      render json: @book, status: :created, location: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      render json: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy
  end

  # POST /books/search
  def search
    if Amazon.validate_url(params[:url])
      item_id = Amazon.get_item_id(params[:url])
      book = Book.find_by asin: item_id

      if book
        render json: book
        puts book.update(Amazon.search(item_id, params[:url]))
      else
        book = Book.new(Amazon.search(item_id, params[:url]))
        book.save
        render json: book
      end
    else
      render json: { error: 'Not a valid www.amazon.cn URL' }, status: :bad_request
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def book_params
      params.require(:book).permit(:name, :asin, :author, :publisher, :published_at, :image, :price, :origin_url, :purchase_url)
    end
end
