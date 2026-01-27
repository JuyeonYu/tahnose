require "test_helper"

class PastesControllerTest < ActionDispatch::IntegrationTest
  test "paste create enforces session cooldown" do
    cache = ActiveSupport::Cache::MemoryStore.new

    Rails.stub(:cache, cache) do
      assert_difference "Paste.count", 1 do
        post pastes_path, params: { paste: { body: "hello", tag: "alpha" } }
      end
      assert_response :redirect

      assert_no_difference "Paste.count" do
        post pastes_path, params: { paste: { body: "again", tag: "beta" } }
      end
      assert_response :too_many_requests
    end
  end

  test "paste create enforces ip rate limit" do
    cache = ActiveSupport::Cache::MemoryStore.new

    Rails.stub(:cache, cache) do
      8.times do |i|
        session = open_session
        session.post pastes_path, params: { paste: { body: "body-#{i}", tag: "tag-#{i}" } }
        session.assert_response :redirect
      end

      session = open_session
      session.post pastes_path, params: { paste: { body: "body-9", tag: "tag-9" } }
      session.assert_response :too_many_requests
    end
  end

  test "search rejects short queries" do
    get pastes_path, params: { q: "a" }
    assert_response :unprocessable_entity
    assert_match I18n.t("flash.pastes.search_too_short", count: PastesController::SEARCH_MIN_QUERY_LENGTH), response.body
  end

  test "search enforces ip rate limit" do
    cache = ActiveSupport::Cache::MemoryStore.new

    Rails.stub(:cache, cache) do
      15.times do
        get pastes_path, params: { q: "ab" }
        assert_response :success
      end

      get pastes_path, params: { q: "ab" }
      assert_response :too_many_requests
    end
  end
end
