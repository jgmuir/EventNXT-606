class Api::V1::EventsController < Api::V1::ApiController
  def index
    events = Event.where(user_id: current_user.id).limit(params[:limit]).offset(params[:offset])
    render json: events.map{ |event|
      with_attachments(event)
    }
  end

  def show
    #@event = Event.find(params[:id])
    @event = Event.find(params[:id])
    #render json: {event: event}
  end

  def create
    par = event_params.to_h
    par[:user_id] = current_user.id
    event = Event.create(par)
    render_valid(event)
    #render json: {params: event_params, event: event}
  end

  def update
    event = Event.find params[:id]
    update_referral_count event
    event.update(event_params)
    render_valid(event)
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

  def event_params
    params.permit(:title, :address, :datetime, :image, :description, :box_office, :last_modified, :user_id)
        #:image, :box_office, :x1, :y1, :x2, :y2, :user_id)
  end

  def render_valid(event)
    @event = event
    if event.valid?
      render json: with_attachments(event)
      #head :ok
      #render json: {event: event, params: params}
      params[:id] = event.id
      @event
    else
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
