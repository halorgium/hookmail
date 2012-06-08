require 'sinatra/base'
require 'pony'

Pony.options = {
  from: ENV.fetch("HOOK_EMAIL_FROM"),
  to: ENV.fetch("HOOK_EMAIL_TO"),
  via: :smtp,
  via_options: {
    address:              ENV.fetch("MAILGUN_SMTP_SERVER"),
    port:                 ENV.fetch("MAILGUN_SMTP_PORT"),
    enable_starttls_auto: true,
    user_name:            ENV.fetch("MAILGUN_SMTP_LOGIN"),
    password:             ENV.fetch("MAILGUN_SMTP_PASSWORD"),
    authentication:       :plain,
    domain:               "hookmail.localdomain",
  },
}

class Hookmail < Sinatra::Base
  post "/hook/#{ENV.fetch("HOOK_KEY")}" do
    body = []
    body << "Headers:"
    request.env.each do |key,value|
      next unless key =~ /^HTTP_(.*)$/
      body << "#{$1}: #{value}"
    end
    body << ""
    body << "Body:"
    body << request.body.read

    Pony.mail(
      subject: "New Hookmail",
      body: body.join("\n"),
    )
    "OK"
  end
end

run Hookmail
