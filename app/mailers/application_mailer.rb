# Top-level class for all outbound email
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
