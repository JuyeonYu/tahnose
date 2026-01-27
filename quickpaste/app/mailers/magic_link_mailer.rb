class MagicLinkMailer < ApplicationMailer
  def login
    @user = params[:user]
    @magic_link = params[:magic_link]

    mail(to: @user.email, subject: I18n.t("mailers.magic_link.subject"))
  end
end
