# Preview all emails at http://localhost:3000/rails/mailers/magic_link_mailer
class MagicLinkMailerPreview < ActionMailer::Preview
  def login
    user = User.first || User.new(email: "preview@example.com")
    magic_link = "https://quick-paste.com/auth/magic?token=preview-token"
    MagicLinkMailer.with(user: user, magic_link: magic_link).login
  end
end
