class ApplicationMailer < ActionMailer::Base
  default from: ENV["RESEND_FROM"] || Rails.application.credentials.dig(:resend, :from) || "from@example.com"
  layout "mailer"
end
