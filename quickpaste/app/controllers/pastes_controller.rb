class PastesController < ApplicationController
  before_action :set_paste, only: %i[show edit update destroy manage]
  before_action :require_manage_token!, only: %i[manage edit update destroy]
  after_action :destroy_read_once_paste_after_show, only: :show, if: -> { @destroy_read_once_after_show }

  # GET /pastes/new
  def index
    @pastes = Paste.order(created_at: :desc)
  end

  def show
    if @paste.locked? && !unlocked?(@paste)
      render :locked, status: :unauthorized
      return
    end
    current_views = @paste.view_count.to_i
    @destroy_read_once_after_show = @paste.read_once && current_views >= 1

    @paste.increment!(:view_count)
  end

  # GET /pastes/new
  def new
    @paste = Paste.new
  end

  # POST /pastes
  def create
    @paste = Paste.new(paste_params)

    if @paste.save
      token = @paste.ensure_manage_token!
      @paste.save! if token.present?

      # 관리 링크는 query로 전달 (예: /pastes/123/manage?token=...)
      @manage_url = manage_paste_url(@paste, token: token)

      flash[:manage_url] = @manage_url
      redirect_to @paste, notice: "게시글이 생성되었습니다.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /pastes/:id/edit
  def edit
  end

  # PATCH /pastes/:id
  def update
    if @paste.update(paste_params)
      redirect_to @paste, notice: "게시글이 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pastes/:id
  def destroy
    @paste.destroy
    redirect_to pastes_path, notice: "게시글이 삭제되었습니다."
  end

  def unlock
    @paste = Paste.find(params[:id])

    if @paste.authenticate(params[:password].to_s)
      session[unlock_session_key(@paste)] = true
      redirect_to @paste
    else
      flash.now[:alert] = "비밀번호가 올바르지 않습니다."
      render :locked, status: :unauthorized
    end
  end

  def manage
    @manage_mode = true
    render :show
  end


  private

  def set_paste
    @paste = Paste.find(params[:id])
  end

  def paste_params
    params.require(:paste).permit(
      :content,
      :expires_at,
      :read_once,
      :password,
      :password_confirmation
    )
  end


  def destroy_read_once_paste_after_show
    @paste.destroy
  end

  def unlocked?(paste)
    session[unlock_session_key(paste)] == true
  end

  def unlock_session_key(paste)
    "paste_unlocked_#{paste.id}"
  end

  def require_manage_token!
    token = params[:token].presence || session_manage_token_for(@paste)
    unless @paste.valid_manage_token?(token)
      render plain: "Unauthorized", status: :unauthorized
      return
    end
    # 한 번 성공하면 세션에 저장해두면 UX가 좋아짐(매번 token 붙일 필요 없음)
    store_session_manage_token(@paste, token) if params[:token].present?
  end

  def session_manage_token_for(paste)
    session.dig(:manage_tokens, paste.id.to_s)
  end

  def store_session_manage_token(paste, token)
    session[:manage_tokens] ||= {}
    session[:manage_tokens][paste.id.to_s] = token
  end
end
