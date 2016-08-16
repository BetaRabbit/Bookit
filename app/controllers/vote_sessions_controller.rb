require 'date'

class VoteSessionsController < ApplicationController
  before_action :set_vote_session, only: [:show, :update, :destroy]

  # GET /@vote_sessions
  def index
    @vote_sessions = VoteSession.all

    render json: @vote_sessions
  end

  # GET /@vote_sessions/1
  def show
    render json: @vote_session
  end

  # POST /@vote_sessions
  def create
    params[:vote_session][:start_date] = Date.today.to_s if params[:vote_session][:start_date].blank?
    @vote_session = VoteSession.new(vote_session_params)

    if @vote_session.save
      render json: @vote_session, status: :created, location: @vote_session
    else
      render json: @vote_session.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /@vote_sessions/1
  def update
    if @vote_session.update(vote_session_params)
      render json: @vote_session
    else
      render json: @vote_session.errors, status: :unprocessable_entity
    end
  end

  # DELETE /@vote_sessions/1
  def destroy
    @vote_session.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote_session
      @vote_session = VoteSession.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vote_session_params
      params.require(:vote_session).permit(:name, :start_date, :end_date, :budget)
    end
end
