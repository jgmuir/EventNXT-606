class Api::V1::EventsController < Api::V1::ApiController
  def index
    render json: {message: 'No bearer token'}, status: :forbidden and return unless current_user
    events = Event.where(user_id: current_user.id).limit(params[:limit]).offset(params[:offset])
    render json: events.map{ |event|
      with_attachments(event)
    }
  end

  def show
    @event = Event.find(params[:id])
    render json: {event: @event}
  end

  def create
    render json: {message: 'No bearer token'}, status: :forbidden and return unless current_user
    par = event_params.to_h
    par[:user_id] = current_user.id
    event = Event.create(par)
    render_valid(event)
    if event.valid?
      event.save
      create_default_templates(event)
      render json: with_attachments(event)
    else
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find params[:id]
    update_referral_count event
    event.update(event_params)
    if event.valid?
      event.save
      render json: with_attachments(event)
    else
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    event = Event.find params[:id]

    if params.has_key? :image
      event.image.purge if event.image.attached?
    end

    if params.has_key? :box_office
      event.box_office.purge if event.box_office.attached?
    end

    unless params.has_key? :partial
      unless event.destroy
        render json: event.errors, status: :unprocessable_entity
        return
      end
    end

    head :ok
  end

  private

  def with_attachments(model)
    image_url = url_for(model.image) if model.image.attached?
    box_office_url = url_for(model.box_office) if model.box_office.attached?
    model.as_json.merge({ image_url: image_url, box_office_url: box_office_url })
  end

  def update_referral_count(event)
    # updates the referral count after updating the box office data by looking for
    # the referred email
    return unless event_params.has_key? :box_office
    prior_emails = event.box_office.open do |file|
      sheet = Roo::Spreadsheet.open(file.path)
      sheet.each(email: 'Email').map { |row| row[:email] }.uniq
    end

    # todo: better to check if files have same content first?
    sheet = Roo::Spreadsheet.open(event_params[:box_office].tempfile.path)
    curr_emails = sheet.each(email: 'Email').map { |row| row[:email] }.uniq
    new_emails = prior_emails.nil? ? curr_emails : curr_emails - prior_emails
    return if new_emails.empty?

    converted_referrals = GuestReferral.select('guest_id, count(guest_id)')
                                       .where(email: new_emails, counted: false)
                                       .group(:guest_id)
    converted_referrals.each { |converted_referral|
      count = converted_referral.count
      guest = converted_referral.guest
      guest.guest_referral_rewards.update_all("count = count + #{count}")
    }
    GuestReferral.where(email: new_emails).update(counted: true)
  end

  def create_default_templates(event)
    rsvp_template = EmailTemplate.new 
    rsvp_template.name = 'RSVP Invitation'
    rsvp_template.subject = '{{event.title}} - Invitation'
    rsvp_template.body = File.read(Rails.root.join('app', 'views', 'guest_mailer', 'rsvp_invitation_email.html'))
    rsvp_template.is_html = true
    rsvp_template.event_id = event.id
    rsvp_template.user_id = current_user.id

    confirmation_template = EmailTemplate.new 
    confirmation_template.name = 'RSVP Confirmation'
    confirmation_template.subject = '{{event.title}} - Confirmation'
    confirmation_template.body = File.read(Rails.root.join('app', 'views', 'guest_mailer', 'rsvp_confirmation_email.html'))
    confirmation_template.is_html = true
    confirmation_template.event_id = event.id
    confirmation_template.user_id = current_user.id
    
    rsvp_template.save
    confirmation_template.save
  end

  def event_params
    params.permit(:title, :address, :datetime, :image, :description, :box_office, :last_modified, :user_id)
        #:image, :box_office, :x1, :y1, :x2, :y2, :user_id)
  end

  def render_valid(event)
  end
end
