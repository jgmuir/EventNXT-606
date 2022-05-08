class GenericMailer < ApplicationMailer
  default subject: '<No subject>'

  def mailer(senders, recipient, subject, body, opts = {})
    from = senders.map { |sender|
      email_address_with_name(sender.email, sender.full_name)
    }
    opts[:attachments].each { |filename, file| attachments[filename] = file } unless opts[:attachments].nil?

    logger.debug 'HERE'
    logger.debug from
    logger.debug email_address_with_name(recipient.email, recipient.full_name)

    mail(
      to: email_address_with_name(recipient.email, recipient.full_name),
      cc: from,
      subject: subject
    ) do |format|
      format.html { render inline: body.html_safe }
      format.text { render plain: opts[:plain] } unless opts[:plain].nil?
    end
  end
end
