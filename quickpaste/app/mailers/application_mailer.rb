class ApplicationMailer < ActionMailer::Base
  default from: ENV["RESEND_FROM"] || Rails.application.credentials.dig(:resend, :from) || "no-reply@quick-paste.com"
  layout "mailer"
end
