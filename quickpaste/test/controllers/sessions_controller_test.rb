require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "magic link requests enforce email cooldown" do
    email = "cooldown@example.com"

    assert_difference ["MagicLinkRequest.count", "LoginToken.count"], 1 do
      post magic_link_path, params: { email: email }
    end
    assert_redirected_to login_path

    assert_no_difference "LoginToken.count" do
      post magic_link_path, params: { email: email }
    end
    assert_response :too_many_requests
    assert_match I18n.t("flash.sessions.magic_link_sent", seconds: SessionsController::MAGIC_LINK_EMAIL_COOLDOWN_SECONDS), response.body
  end

  test "magic link requests enforce ip rate limit" do
    with_memory_cache do
      5.times do |i|
        post magic_link_path, params: { email: "user#{i}@example.com" }
        assert_response :redirect
      end

      post magic_link_path, params: { email: "overflow@example.com" }
      assert_response :too_many_requests
    end
  end

  test "magic link resend reuses active token" do
    with_memory_cache do
      email = "resend@example.com"
      user = User.create!(email: email)
      user.identities.create!(provider: "email", email: email)

      raw_token = LoginToken.generate_for!(user)
      Rails.cache.write(
        "magic_link:token:#{Digest::SHA256.hexdigest(email)}",
        raw_token,
        expires_in: LoginToken::EXPIRY_DURATION
      )

      assert_no_difference "LoginToken.count" do
        post magic_link_resend_path, params: { email: email }
      end
      assert_redirected_to login_path
    end
  end

  private

  def with_memory_cache
    old_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = old_cache
  end
end
