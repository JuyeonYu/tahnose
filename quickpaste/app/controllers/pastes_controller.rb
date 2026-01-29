class PastesController < ApplicationController
  helper_method :unlocked?, :paste_permission_via
  PASTE_CREATE_IP_LIMIT = 15
  PASTE_CREATE_IP_PERIOD_SECONDS = 60
  SEARCH_IP_LIMIT = 15
  SEARCH_IP_PERIOD_SECONDS = 60
  SEARCH_MIN_QUERY_LENGTH = 2

  before_action :set_paste, only: %i[show edit update destroy manage]
  before_action :require_manage_token!, only: %i[manage edit update destroy]
  before_action :require_login!, only: :mine
  after_action :destroy_read_once_paste_after_show, only: :show, if: -> { @destroy_read_once_after_show }

  # GET /pastes/new
  def index
    @query = params[:q].to_s
    @notices = []

    if @query.present?
      if @query.length < SEARCH_MIN_QUERY_LENGTH
        flash.now[:alert] = t("flash.pastes.search_too_short", count: SEARCH_MIN_QUERY_LENGTH)
        @pagy, @pastes = pagy(Paste.none)
        render :index, status: :unprocessable_entity
        return
      end

      @pagy, @pastes = pagy(Paste.none)
      unless ip_rate_limit!(
        scope: "search",
        limit: SEARCH_IP_LIMIT,
        period_seconds: SEARCH_IP_PERIOD_SECONDS,
        view: :index
      )
        return
      end
    end

    scope = Paste.search(@query)
    if @query.blank?
      @notices = Paste.notices.order(created_at: :desc)
      scope = scope.where(notice: false)
    end

    scope = scope.order(created_at: :desc)
    @pagy, @pastes = pagy(scope)
  end

  def mine
    @pastes = current_user.pastes.order(created_at: :desc)
    render :mine
  end

  def show
    if @paste.locked? && !unlocked?(@paste)
      render :locked, status: :unauthorized
      return
    end

    if @paste.read_once && !read_once_confirmed?
      render :read_once, status: :ok
      return
    end

    @paste.increment!(:view_count)
    @destroy_read_once_after_show = @paste.read_once
  end

  # GET /pastes/new
  def new
    @paste = Paste.new
  end

  # POST /pastes
  def create
    @paste = Paste.new(paste_params)
    @paste.owner = current_user if logged_in?

    unless ip_rate_limit!(
      scope: "pastes_create",
      limit: PASTE_CREATE_IP_LIMIT,
      period_seconds: PASTE_CREATE_IP_PERIOD_SECONDS,
      view: :new
    )
      return
    end

    if @paste.save
      allow_owner_bypass!
      unless logged_in?
        token = @paste.ensure_manage_token!
        @paste.save! if token.present?

        # 관리 링크는 query로 전달 (예: /pastes/123/manage?token=...)
        @manage_url = manage_paste_url(@paste, token: token)
        flash[:manage_url] = t("flash.pastes.manage_link", url: @manage_url)
      end

      redirect_to paste_path(@paste, ga: "paste_created"),
        notice: t("flash.pastes.created"),
        status: :see_other

    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /pastes/:id/edit
  def edit
  end

  # PATCH /pastes/:id
  def update
    if @paste.update(paste_update_params)
      redirect_to @paste, notice: t("flash.pastes.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pastes/:id
  def destroy
    @paste.destroy
    redirect_to pastes_path, notice: t("flash.pastes.deleted")
  end

  def unlock
    @paste = Paste.find(params[:id])

    if @paste.authenticate(params[:password].to_s)
      store_paste_permission(@paste, :password)
      redirect_to @paste
    else
      flash.now[:alert] = t("flash.pastes.invalid_password")
      render :locked, status: :unauthorized
    end
  end

  def manage
    @manage_mode = true
    render :show
  end

  def confirm_read_once
    @paste = Paste.find(params[:id])
    session[read_once_session_key(@paste)] = true
    redirect_to @paste
  end


  private

  def set_paste
    @paste = Paste.find(params[:id])
  end

  def paste_params
    params.require(:paste).permit(
      :body,
      :tag,
      :read_once,
      :password
    )
  end

  def paste_update_params
    params.require(:paste).permit(
      :body,
      :read_once,
      :password
    )
  end


  def destroy_read_once_paste_after_show
    @paste.destroy
    session.delete(read_once_session_key(@paste))
  end

  def unlocked?(paste)
    paste_permission_via(paste).present?
  end

  def paste_permission_via(paste)
    stored = session.dig(:paste_permissions, paste.id.to_s)
    return stored.to_sym if stored.present?

    return nil unless paste.locked?
    return nil unless logged_in? && paste.owner == current_user

    store_paste_permission(paste, :owner)
    :owner
  end

  def read_once_confirmed?
    session[read_once_session_key(@paste)] == true
  end

  def read_once_session_key(paste)
    "paste_read_once_confirmed_#{paste.id}"
  end

  def allow_owner_bypass!
    store_paste_permission(@paste, :owner) if @paste.locked?
  end

  def require_manage_token!
    return if logged_in? && @paste.owner == current_user

    token = params[:token].presence || session_manage_token_for(@paste)
    unless @paste.valid_manage_token?(token)
      render plain: t("errors.unauthorized"), status: :unauthorized
      return
    end
    # 한 번 성공하면 세션에 저장해두면 UX가 좋아짐(매번 token 붙일 필요 없음)
    store_session_manage_token(@paste, token) if params[:token].present?
    store_paste_permission(@paste, :owner) if @paste.locked?
  end

  def session_manage_token_for(paste)
    session.dig(:manage_tokens, paste.id.to_s)
  end

  def store_session_manage_token(paste, token)
    session[:manage_tokens] ||= {}
    session[:manage_tokens][paste.id.to_s] = token
  end

  def store_paste_permission(paste, via)
    session[:paste_permissions] ||= {}
    session[:paste_permissions][paste.id.to_s] = via.to_s
  end
end
