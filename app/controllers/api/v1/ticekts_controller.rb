class Api::V1::TicketsController < Api::V1::ApiController
    def show
      if params.has_key?(:seat_id)
        tickets = GuestSeatTicket.where(guest_id: params[:id], seat_id: params[:seat_id])
      else
        tickets = GuestSeatTicket.where(guest_id: params[:id])
      end
      render json: tickets
    end
  
    def create
      ticket = GuestSeatTicket.new(ticket_create_params)
      if ticket.save
        render json: ticket
      else
        render json: ticket.errors, status: :unprocessable_entity
      end
    end
  
    def update
      ticket = GuestSeatTicket.find_by guest_id: params[:id], seat_id: params[:seat_id]
      
      if ticket.update(ticket_update_params)
        render json: ticket
      else
        render json: ticket.errors, status: :unprocessable_entity
      end
    end
  
    def destroy
      if params.has_key? :seat_id
        tickets = GuestSeatTicket.where guest_id: params[:id], seat_id: params[:seat_id]
      else
        tickets = GuestSeatTicket.where guest_id: params[:id]
      end
  
      if tickets.destroy_all
        head :ok
      else
        render json: ticket.errors, status: :unprocessable_entity
      end
    end
  
    private
  
    def ticket_create_params
      p = params.permit(:id, :seat_id, :committed, :allotted).to_h
      p[:guest_id] = p.delete :id
      return p
    end
  
    def ticket_update_params
      params.permit(:committed, :allotted)
    end
  end