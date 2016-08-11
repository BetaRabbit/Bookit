class BooksController < ApplicationController
  require 'api/amazon'
  require 'api/jd'

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
      api = Amazon
      item_id_type = 'asin'
    elsif Jd.validate_url(params[:url])
      api = Jd
      item_id_type = 'jd_id'
    else
      render json: { error: 'Not a valid www.amazon.cn or www.jd.com URL' }, status: :bad_request
      return
    end

    # Find duplicates by ASIN (Amazon) or JDID (JD),
    # different retailers are be treated as different items,
    # because there is no effective way to distinguish them.
    item_id = api.get_item_id(params[:url])
    book = Book.find_by "#{item_id_type}": item_id

    if book
      render json: book
    else
      new_book = api.search(item_id, params[:url])
      if new_book
        book = Book.new(new_book)
        book.save
        render json: book
      else
        render json: { error: 'Cannot read data from provided URL' }, status: :bad_request
      end
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
