class Api::V1::GuestsController < Api::V1::ApiController
  include Api::V1::EmailHelper

  def index
    guests = Guest.where(event_id: params[:event_id]).limit(params[:limit]).offset(params[:offset])
    if params.has_key? :download
      event_title = Event.find(params[:event_id]).title.gsub ' ', '_'
      filename = "#{event_title}-guests-#{Time.now.strftime('%Y%m%d-%H%M%S')}.csv"
      send_data guests.to_csv, type: 'text/csv', filename: filename
      return json
    end

    # render the results with ticket allotments merged in
    render json: guests.map {|guest|
      guest.as_json.merge({allotments: guest.guest_seat_tickets.as_json});
    }
  end

  def show
    guest = Guest.find(params[:id])
    if guest
      render json: guest
    else
      render json: guest.errors(), status: :not_found
    end
  end
  
  def invite
    guest = Guest.find(params[:id])
    if guest.booked and !params.has_key? :resend
      res = {:message => "#{guest.first_name} #{guest.last_name} has already confirmed this invitation."}
      render json: res
      return
    end
    
    # GuestMailer.rsvp_invitation_email(guest.event, guest).deliver_now
    template = EmailTemplate.where(name: "RSVP Invitation").first
    gen_email_from_template([current_user.email], guest.email, template)
    if guest.update({:invited_at => Time.now})
      head :ok
    else
      render json: guest.errors(), status: :unprocessable_entity
    end
  end

  def book
    guest = Guest.find(params[:id])

    guest.update_attribute :booked, params[:accept].present?
    guest.reload

    if !guest.booked
      head :ok
      return
    end

    params_confirm = params.require(:seats).permit([:seat_id, :committed])

    event = Event.find(params[:event_id])
    seats = params_confirm[:seats].to_h

    seats.each {|_, h| 
      guest.seats.where(guest_id: params[:id], seat_id: h[:seat_id]).update_all(committed: h[:committed])
    }

    # todo: customize which and how many tickets were comitted
    template = EmailTemplate.where(name: "RSVP Confirmation").first
    gen_email_from_template([current_user.email], guest.email, template)
    head :ok
  end

  def checkin
    guest = Guest.find(params[:id])
    if guest.update({checked: true})
      head :ok
    else
      head :unprocessable_entity
    end
  end
  
  def create
    guest = Guest.new(guest_params_create)
    guest.save
    if guest.save
      render json: guest.to_json, status: :created
    else
      render json: guest.errors, status: :unprocessable_entity
    end
  end
  
  def update
    guest = Guest.find(params[:id])
    if guest.update(guest_params_update)
      render json: guest.to_json, status: :ok
    else
      render json: guest.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    guest = Guest.find(params[:id])
    guest.destroy
    head :ok 
  end
  
  private

  def guest_params_update
    params.permit(
      :email, :first_name, :last_name, :affiliation, :type, 
      :invite_expiration, :referral_expiration, :invited_at,
      :event_id)
  end

  def guest_params_create
    params.permit(
      :email, :first_name, :last_name, :affiliation, :type,
      :invite_expiration, :referral_expiration, :invited_at,
      :event_id, :added_by)
  end
end