require "test_helper"

class PastesControllerTest < ActionDispatch::IntegrationTest
  test "owner can edit and update their paste" do
    user = User.create!(email: "owner@example.com")
    paste = Paste.create!(body: "hello", tag: "mine", owner: user)

    log_in_as(user)

    get edit_paste_path(paste)
    assert_response :success

    patch paste_path(paste), params: { paste: { body: "updated", read_once: false } }
    assert_redirected_to paste_path(paste)
    assert_equal "updated", paste.reload.body
  end

  test "owner can delete their paste" do
    user = User.create!(email: "owner@example.com")
    paste = Paste.create!(body: "delete me", tag: "mine", owner: user)

    log_in_as(user)

    assert_difference "Paste.count", -1 do
      delete paste_path(paste)
    end
    assert_redirected_to pastes_path
  end

  test "paste create allows consecutive requests within limit" do
    with_memory_cache do
      assert_difference "Paste.count", 2 do
        post pastes_path, params: { paste: { body: "hello", tag: "alpha" } }
        assert_response :redirect

        post pastes_path, params: { paste: { body: "again", tag: "beta" } }
        assert_response :redirect
      end
    end
  end

  test "paste create enforces ip rate limit" do
    with_memory_cache do
      15.times do |i|
        session = open_session
        session.post pastes_path, params: { paste: { body: "body-#{i}", tag: "tag-#{i}" } }
        session.assert_response :redirect
      end

      session = open_session
      session.post pastes_path, params: { paste: { body: "body-16", tag: "tag-16" } }
      session.assert_response :too_many_requests
    end
  end

  test "search rejects short queries" do
    get pastes_path, params: { q: "a" }
    assert_response :unprocessable_entity
    assert_match I18n.t("flash.pastes.search_too_short", count: PastesController::SEARCH_MIN_QUERY_LENGTH), response.body
  end

  test "search enforces ip rate limit" do
    with_memory_cache do
      15.times do
        get pastes_path, params: { q: "ab" }
        assert_response :success
      end

      get pastes_path, params: { q: "ab" }
      assert_response :too_many_requests
    end
  end

  private

  def log_in_as(user)
    token = LoginToken.generate_for!(user)
    get auth_magic_path(token: token)
    assert_redirected_to pastes_path
  end

  def with_memory_cache
    old_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = old_cache
  end
end
