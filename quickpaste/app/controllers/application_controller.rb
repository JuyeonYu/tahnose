class ApplicationController < ActionController::Base
  include Pagy::Method
  include RateLimitable
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # == Session-based Authentication (skeleton)
  helper_method :current_user, :logged_in?, :admin?, :auth_enabled?

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    return @current_user if defined?(@current_user)

    user_id = session[:user_id]
    @current_user = user_id.present? ? User.find_by(id: user_id) : nil
  end

  def logged_in?
    current_user.present?
  end

  def auth_enabled?
    ENV.fetch("AUTH_ENABLED", "true").downcase == "true"
  end

  def admin?
    return false unless current_user.present?

    admin_email = ENV["ADMIN_EMAIL"].presence
    return false unless admin_email

    current_user.email == admin_email
  end

  # Use this as a before_action for pages that require authentication
  def require_login!
    return unless auth_enabled?
    return if logged_in?

    store_return_to
    redirect_to login_path, alert: t("flash.sessions.login_required")
  end

  # Use this as a before_action for authentication-related pages
  def require_auth_enabled!
    return if auth_enabled?

    redirect_to root_path
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

  def render_not_found
    render "errors/not_found", status: :not_found
  end
end
