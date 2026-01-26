class MagicLinkMailer < ApplicationMailer
  def login
    @user = params[:user]
    @magic_link = params[:magic_link]

    mail(to: @user.email, subject: "로그인 링크")
  end
end
