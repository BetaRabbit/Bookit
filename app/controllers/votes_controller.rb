class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :update, :destroy]

  # GET /votes
  def index
    @votes = Vote.all

    render json: @votes
  end

  # GET /votes/1
  def show
    render json: @vote
  end

  # POST /votes
  def create
    vote_session = VoteSession.find(vote_params[:vote_session])
    book = Book.find(vote_params[:book])
    user = User.find(vote_params[:user])

    @vote = Vote.new(
      vote_session: vote_session,
      book: book,
      user: user
    )

    if @vote.save
      render json: @vote, status: :created, location: @vote
    else
      render json: @vote.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /votes/1
  def update
    if @vote.update(vote_params)
      render json: @vote
    else
      render json: @vote.errors, status: :unprocessable_entity
    end
  end

  # DELETE /votes/1
  def destroy
    @vote.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote
      @vote = Vote.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vote_params
      params.require(:vote).permit(:user, :book, :vote_session)
    end
end
