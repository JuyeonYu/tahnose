class PastesController < ApplicationController
  before_action :set_paste, only: %i[show edit update destroy]
  after_action :destroy_read_once_paste_after_show, only: :show, if: -> { @destroy_read_once_after_show }

  # GET /pastes/new
  def index
    @pastes = Paste.all
  end


  def show
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
      redirect_to @paste, notice: "게시글이 생성되었습니다."
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


  private

  def set_paste
    @paste = Paste.find(params[:id])
  end

  def paste_params
    params.require(:paste).permit(
      :content,
      :expires_at,
      :read_once
    )
  end


  def destroy_read_once_paste_after_show
    @paste.destroy
  end
end
