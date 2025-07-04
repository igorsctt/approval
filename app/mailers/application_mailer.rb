# Application Mailer base class

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL', 'noreply@approvalworkflow.com')
  layout 'mailer'

  protected

  def format_date(date)
    date&.strftime('%B %d, %Y at %I:%M %p UTC')
  end

  def format_time_remaining(seconds)
    return 'Expired' if seconds <= 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60

    if hours > 0
      "#{hours} hour#{'s' if hours != 1}"
    elsif minutes > 0
      "#{minutes} minute#{'s' if minutes != 1}"
    else
      'Less than a minute'
    end
  end
end
