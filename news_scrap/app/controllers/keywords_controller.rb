class KeywordsController < ApplicationController
  def index
    @keywords = Keyword.all
  end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)

    if @keyword.save
      redirect_to keywords_path, notice: 'Keyword created'
    else
      render :new,
             status: :unproccessable_entity
    end
  end

  def show
    @keyword = Keyword.find(params[:id])
    @articles = NewsFetcher.call(keyword: @keyword)
  end

  def update
    @keyword = Keyword.find(params[:id])

    @keyword.update!(on_alarm: !@keyword.on_alarm)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to keywords_path }
    end
  end

  def toggle_alarm
    @keyword = Keyword.find(params[:id])

    @keyword.update!(on_alarm: !@keyword.on_alarm)
    redirect_to keywords_path
  end

  private

  def keyword_params
    params.require(:keyword).permit(:title, :exeption)
  end
end
