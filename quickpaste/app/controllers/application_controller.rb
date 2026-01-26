class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # == Session-based Authentication (skeleton)
  helper_method :current_user, :logged_in?

  private

  def current_user
    return @current_user if defined?(@current_user)

    user_id = session[:user_id]
    @current_user = user_id.present? ? User.find_by(id: user_id) : nil
  end

  def logged_in?
    current_user.present?
  end

  # Use this as a before_action for pages that require authentication
  def require_login!
    return if logged_in?

    store_return_to
    redirect_to login_path, alert: "로그인이 필요합니다. 이메일로 로그인 링크를 받아주세요."
  end

  # Store return location so we can redirect back after magic-link login
  def store_return_to
    # Avoid storing non-GET requests or authentication endpoints
    return unless request.get?
    return if request.xhr?

    disallowed_paths = [
      login_path,
      auth_magic_path,
      logout_path
    ].compact

    return if disallowed_paths.any? { |p| p.present? && request.path == p }

    session[:return_to] = request.fullpath
  end

  def pop_return_to
    session.delete(:return_to)
  end
end
