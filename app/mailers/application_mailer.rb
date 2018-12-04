# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "noreply@bootcamp.fjord.jp"
  layout "mailer"
end
