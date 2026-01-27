module RateLimitable
  private

  def ip_rate_limit!(scope:, limit:, period_seconds:, message: nil, view: nil)
    message ||= I18n.t("errors.rate_limited")
    key = "rl:#{scope}:ip:#{request.remote_ip}"
    count = cache_increment(key, period_seconds)
    started_at = cache_started_at(key, period_seconds)

    return true if count <= limit

    retry_after = remaining_seconds(started_at, period_seconds)
    render_rate_limited!(message: message, retry_after: retry_after, view: view)
    false
  end

  def session_cooldown!(key:, seconds:, message: nil, view: nil)
    message ||= I18n.t("errors.rate_limited")
    last_at = session[key].to_i
    if last_at.positive?
      elapsed = Time.current.to_i - last_at
      if elapsed < seconds
        retry_after = seconds - elapsed
        render_rate_limited!(message: message, retry_after: retry_after, view: view)
        return false
      end
    end

    session[key] = Time.current.to_i
    true
  end

  def render_rate_limited!(message:, retry_after: nil, view: nil)
    response.headers["Retry-After"] = retry_after.to_i.to_s if retry_after.present?

    respond_to do |format|
      format.html do
        if view.present?
          flash.now[:alert] = message
          render view, status: :too_many_requests
        else
          render plain: message, status: :too_many_requests
        end
      end
      format.json do
        payload = { error: message }
        payload[:retry_after] = retry_after.to_i if retry_after.present?
        render json: payload, status: :too_many_requests
      end
      format.any { render plain: message, status: :too_many_requests }
    end
  end

  def cache_increment(key, expires_in)
    count = Rails.cache.increment(key, 1, expires_in: expires_in)
    return count if count

    Rails.cache.write(key, 1, expires_in: expires_in)
    1
  end

  def cache_started_at(key, expires_in)
    started_key = "#{key}:started_at"
    Rails.cache.fetch(started_key, expires_in: expires_in) { Time.current.to_i }
  end

  def remaining_seconds(started_at, period_seconds)
    remaining = period_seconds - (Time.current.to_i - started_at.to_i)
    remaining.positive? ? remaining : 0
  end
end
