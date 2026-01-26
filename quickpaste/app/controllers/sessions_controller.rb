class SessionsController < ApplicationController
  MAGIC_LINK_EMAIL_COOLDOWN_SECONDS = 60
  MAGIC_LINK_RESEND_COOLDOWN_SECONDS = 120
  MAGIC_LINK_IP_LIMIT = 5
  MAGIC_LINK_IP_PERIOD_SECONDS = 60

  def new
    prepare_magic_link_form
  end

  def create
    email = normalize_email(params[:email])
    @prefilled_email = email
    prepare_magic_link_form
    if email.blank?
      flash.now[:alert] = "이메일을 입력해주세요."
      render :new, status: :unprocessable_entity
      return
    end

    unless ip_rate_limit!(
      scope: "magic_link",
      limit: MAGIC_LINK_IP_LIMIT,
      period_seconds: MAGIC_LINK_IP_PERIOD_SECONDS,
      message: magic_link_notice(MAGIC_LINK_EMAIL_COOLDOWN_SECONDS),
      view: :new
    )
      return
    end

    remaining = MagicLinkRequest.cooldown_remaining_seconds(email, MAGIC_LINK_EMAIL_COOLDOWN_SECONDS)
    if remaining.positive?
      render_rate_limited!(
        message: magic_link_notice(MAGIC_LINK_EMAIL_COOLDOWN_SECONDS),
        retry_after: remaining,
        view: :new
      )
      return
    end

    user = find_or_create_user_for_email(email)
    return if performed?

    raw_token = generate_magic_link_token(user, email: email)
    record_magic_link_request!(email)
    deliver_magic_link!(user, raw_token)

    set_magic_link_session!(email, MAGIC_LINK_EMAIL_COOLDOWN_SECONDS)
    redirect_to login_path, notice: magic_link_notice(MAGIC_LINK_EMAIL_COOLDOWN_SECONDS)
  end

  def resend_magic_link
    email = normalize_email(params[:email].presence || session[:last_magic_link_email])
    @prefilled_email = email
    prepare_magic_link_form
    if email.blank?
      flash.now[:alert] = "이메일을 입력해주세요."
      render :new, status: :unprocessable_entity
      return
    end

    remaining = MagicLinkRequest.cooldown_remaining_seconds(email, MAGIC_LINK_RESEND_COOLDOWN_SECONDS)
    if remaining.positive?
      render_rate_limited!(
        message: magic_link_notice(MAGIC_LINK_RESEND_COOLDOWN_SECONDS),
        retry_after: remaining,
        view: :new
      )
      return
    end

    user = find_or_create_user_for_email(email)
    return if performed?

    raw_token = fetch_cached_magic_link_token(email)
    if raw_token.present? && LoginToken.find_active_by_raw_token(raw_token).present?
      record_magic_link_request!(email)
      deliver_magic_link!(user, raw_token)
      set_magic_link_session!(email, MAGIC_LINK_RESEND_COOLDOWN_SECONDS)
      redirect_to login_path, notice: magic_link_notice(MAGIC_LINK_RESEND_COOLDOWN_SECONDS)
      return
    end

    raw_token = generate_magic_link_token(user, email: email)
    record_magic_link_request!(email)
    deliver_magic_link!(user, raw_token)

    set_magic_link_session!(email, MAGIC_LINK_RESEND_COOLDOWN_SECONDS)
    redirect_to login_path, notice: magic_link_notice(MAGIC_LINK_RESEND_COOLDOWN_SECONDS)
  end

  def magic
    token = LoginToken.find_active_by_raw_token(params[:token])
    if token.nil?
      redirect_to login_path, alert: "로그인 링크가 유효하지 않거나 만료되었습니다."
      return
    end

    token.use!
    session[:user_id] = token.user_id

    redirect_to pop_return_to || pastes_path, notice: "로그인되었습니다."
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "로그아웃되었습니다."
  end

  private

  def prepare_magic_link_form
    @prefilled_email ||= session[:last_magic_link_email]
    @resend_cooldown_seconds = magic_link_cooldown_remaining
  end

  def magic_link_cooldown_remaining
    cooldown_until = session[:magic_link_cooldown_until].to_i
    remaining = cooldown_until - Time.current.to_i
    remaining.positive? ? remaining : 0
  end

  def normalize_email(value)
    value.to_s.strip.downcase
  end

  def find_or_create_user_for_email(email)
    identity = Identity.find_by(provider: "email", email: email)
    user = identity&.user
    return user if user.present?

    user = User.new(email: email)
    unless user.save
      flash.now[:alert] = user.errors.full_messages.to_sentence
      prepare_magic_link_form
      render :new, status: :unprocessable_entity
      return
    end

    identity = user.identities.build(provider: "email", email: email)
    unless identity.save
      flash.now[:alert] = identity.errors.full_messages.to_sentence
      prepare_magic_link_form
      render :new, status: :unprocessable_entity
      return
    end

    user
  end

  def magic_link_notice(seconds)
    "메일을 보냈습니다. 스팸함을 확인해주세요. #{seconds}초 후 재요청 가능합니다."
  end

  def deliver_magic_link!(user, raw_token)
    magic_link = auth_magic_url(token: raw_token)
    MagicLinkMailer.with(user: user, magic_link: magic_link).login.deliver_now
  end

  def generate_magic_link_token(user, email:)
    raw_token = LoginToken.generate_for!(user, request: request)
    Rails.cache.write(magic_link_cache_key(email), raw_token, expires_in: LoginToken::EXPIRY_DURATION)
    raw_token
  end

  def fetch_cached_magic_link_token(email)
    Rails.cache.read(magic_link_cache_key(email))
  end

  def magic_link_cache_key(email)
    digest = Digest::SHA256.hexdigest(email)
    "magic_link:token:#{digest}"
  end

  def record_magic_link_request!(email)
    MagicLinkRequest.record!(email: email, requested_at: Time.current, ip: request.remote_ip)
  end

  def set_magic_link_session!(email, cooldown_seconds)
    session[:last_magic_link_email] = email
    session[:magic_link_cooldown_until] = Time.current.to_i + cooldown_seconds
    prepare_magic_link_form
  end
end
