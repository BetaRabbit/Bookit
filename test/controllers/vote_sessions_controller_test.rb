require 'test_helper'

class VoteSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vote_session = vote_sessions(:one)
  end

  test "should get index" do
    get vote_sessions_url, as: :json
    assert_response :success
  end

  test "should create @vote_session" do
    assert_difference('VoteSession.count') do
      post vote_sessions_url, params: {vote_session: {budget: @vote_session.budget, end_date: @vote_session.end_date, name: @vote_session.name, start_date: @vote_session.start_date } }, as: :json
    end

    assert_response 201
  end

  test "should show @vote_session" do
    get vote_session_url(@vote_session), as: :json
    assert_response :success
  end

  test "should update @vote_session" do
    patch vote_session_url(@vote_session), params: {vote_session: {budget: @vote_session.budget, end_date: @vote_session.end_date, name: @vote_session.name, start_date: @vote_session.start_date } }, as: :json
    assert_response 200
  end

  test "should destroy @vote_session" do
    assert_difference('VoteSession.count', -1) do
      delete vote_session_url(@vote_session), as: :json
    end

    assert_response 204
  end
end
