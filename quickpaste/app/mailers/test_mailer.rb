# app/mailers/test_mailer.rb
class TestMailer < ApplicationMailer
  def ping(to:)
    mail(
      to: to,
      subject: "quick-paste 테스트 메일",
      body: "이 메일이 보이면 Resend 설정은 정상입니다."
    )
  end
end
