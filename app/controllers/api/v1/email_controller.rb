class Api::V1::EmailController < Api::V1::ApiController
    def create
      # prototype functionality: to field is default email while senders are cc'd
      # ideally to field is user email and cc is specified by user
      senders = User.find(params[:senders])
      guests = !params[:all_from].nil? ? Guest.where(event_id: params[:all_from])
                                       : Guest.where(id: params[:recipients])
  
      template = EmailTemplate.find(params[:template_id]) unless params[:template_id].nil?
  
      # note: attachments are tempfiles here
      attachments = params[:attachments].map { |attachment|
        [attachment.original_filename.to_s, File.read(attachment.tempfile)]
      }.to_h unless params[:attachments].nil?
  
      unless template.nil?
        outbox = gen_email_from_template(
          senders, guests, template, attachments: attachments)
      else
        outbox = gen_email(
          senders, guests, params[:subject], params[:body], attachments: attachments)
      end
      outbox.each { |mail| mail.deliver_later }
  
      guests.update_all({ emailed_at: Time.now })
      head :ok
    end
  
    private
  
    def gen_email(senders, guests, subject, body, opts = {})
      guests.map { |guest|
        GenericMailer.mailer(
          senders, guest, subject, body, attachments: opts[:attachments])
      }
    end
  
    def gen_email_from_template(senders, guests, template, opts = {})
      # todo: allow for user-defined arguments in template
      # map filenames to urls and convert to struct for ease of access
      links = if template.attachments.attached?
        OpenStruct.new template.attachments.map { |attachment|
          [attachment.filename.to_s.gsub(/[^0-9A-Za-z]/, '_'), url_for(attachment)]
        }.to_h
      end
  
      attachments = if template.attachments.attached?
        template.attachments.map { |attachment| [attachment.filename.to_s, attachment.download] }.to_h
      end
  
      unless opts[:attachments].nil?
        attachments = attachments.merge(opts[:attachments])
      end
  
      # render an email from template for each guest
      guests.map { |guest|
        subject = opts[:subject].nil? ? template.subject : opts[:subject]
        subject = Mustache.render(subject, event: guest.event, guest: guest)
  
        body = Mustache.render(template.body, event: guest.event, guest: guest, links: links)
        if template.is_html
          body = Rails::Html::SafeListSanitizer.new.sanitize(body)
          plain = Rails::Html::SafeListSanitizer.new.sanitize(
            body, tags: %w(a img strong em b i u s table tr td ))
        end
  
        GenericMailer.mailer(
          senders, guest, subject, body, plain: plain, attachments: attachments)
      }
    end
  end