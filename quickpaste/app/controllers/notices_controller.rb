class NoticesController < ApplicationController
  before_action :require_admin!, except: :show
  before_action :set_notice, only: %i[show edit update destroy]

  def show
  end

  def new
    @notice = Notice.new
  end

  def create
    @notice = Notice.new(notice_params)

    if @notice.save
      redirect_to root_path, notice: t("flash.notices.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @notice.update(notice_params)
      redirect_to root_path, notice: t("flash.notices.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @notice.destroy
    redirect_to root_path, notice: t("flash.notices.deleted")
  end

  private

  def require_admin!
    return if admin?

    redirect_to root_path, alert: t("errors.unauthorized")
  end

  def set_notice
    @notice = Notice.find(params[:id])
  end

  def notice_params
    params.require(:notice).permit(:title, :content)
  end
end
