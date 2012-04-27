require 'iron_worker'
require 'mail'

class EmailWorker < IronWorker::Base

  attr_accessor :email_domain, :username, :password, :from, :home_team, :away_team, :time, :users

  def run
    init_mail
    body = "Hope you enjoy the game!"
    subject = "MLB.tv free game: " + away_team + " @ " + home_team + " at " + time
    send_mail(subject: subject, users: users, body: body, from: from)
  end

  # Configures smtp settings to send email.
  def init_mail
    mail_conf = {:address              => "smtp.gmail.com",
             :port                 => 587,
             :domain               => email_domain,
             :user_name            => username,
             :password             => password,
             :authentication       => 'plain',
             :enable_starttls_auto => true}
    Mail.defaults do
        # This is the configuration for sending through Gmail
        delivery_method :smtp, mail_conf
    end
  end
  

  def send_mail(info = {})
    from = info[:from]
    subject = info[:subject]
    body = info[:body]
    users = info[:users]
    users.each do |user|
      mail = Mail.new
      mail[:from]    = from
      mail[:to]      = user["email"]
      mail[:subject] = subject
      html_part      = Mail::Part.new do
        content_type('text/html; charset=UTF-8')
        body(body)
      end
      mail.html_part = html_part
      mail.deliver!
    end
  end

end