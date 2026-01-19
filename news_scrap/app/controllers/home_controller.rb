class HomeController < ApplicationController
  def index
    @keywords = Keyword.all
  end
end
