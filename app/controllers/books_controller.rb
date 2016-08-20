class BooksController < ApplicationController
  require 'api/amazon'
  require 'api/jd'

  before_action :set_book, only: [:show, :update, :destroy]

  # GET /books
  def index
    @books = []

    if params[:vote_session_id]
      vote_session = VoteSession.includes(:books, :votes).find(params[:vote_session_id])
      @books = vote_session.books
    else
      @books = Book.all
    end

    @books = @books.map do |b|
      { votes: b.votes }.merge(b.as_json)
    end

    render json: @books
  end

  # GET /books/1
  def show
    @book = { votes: @book.votes }.merge @book.as_json
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
    new_book = api.search(item_id, params[:url])

    if new_book
      if book
        book.update(new_book)
        render json: book.as_json.merge({ votes: book.votes })
      else
        book = Book.new(new_book)
        book.save
        render json: book.as_json.merge({ votes: book.votes })
      end
    else
      render json: { error: 'Cannot read data from provided URL' }, status: :bad_request
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def book_params
      params.require(:book).permit(:name, :asin, :jd_id, :author, :publisher, :published_at, :image, :price, :origin_url, :purchase_url)
    end
end
