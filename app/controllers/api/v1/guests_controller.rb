class Api::V1::GuestsController < Api::V1::ApiController
  def index
    guests = Guest.where(event_id: params[:event_id])
    render json: guests
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
    guest = Guest.find(params[:guest_id])
    if guest.booked and !params.has_key? :resend
      res = {:message => "#{guest.first_name} #{guest.last_name} has already confirmed this invitation."}
      render json: res
      return
    end
    
    GuestMailer.rsvp_invitation_email(guest.event, guest).deliver_now
    if guest.update({:invited_at => Time.now})
      head :ok
    else
      render json: guest.errors(), status: :unprocessable_entity
    end
  end

  def book
    # VIP guest updates RSVP information (Other infos updated by event owner is handled by update_in_place)
    # {
    #   :id - guest id
    #   :seats => {
    #     {
    #      :seats_id - seats id,
    #      :committed - integer
    #     }
    #   }
    # }
    guest = Guest.find(params[:guest_id])

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
      guest.seats.where(guest_id: params[:guest_id], seat_id: h[:seat_id]).update_all(committed: h[:committed])
    }

    # todo: customize which and how many tickets were comitted
    GuestMailer.rsvp_confirmation_email(event, guest).deliver
    head :ok
  end

  def email
    # todo: send custom email
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
    render status: :ok 
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