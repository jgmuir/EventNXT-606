class Api::V1::SeatsController < Api::V1::ApiController
  # GET /seats or /seats.json
  def index
    seats = Seat.where(event_id: params[:event_id]).limit(params[:limit]).offset(params[:offset])
    render json: seats
  end

  # GET /seats/1 or /seatss/1.json
  def show
    seat = Seat.find(params[:id])
    render json: seat
  end

  # POST /seats or /seats.json
  def create
    seat = Seat.new(seats_params)
    seat.event_id = params[:event_id]

    if seat.save
      render json: seat
    else
      render json: seat.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /seats/1 or /seats/1.json
  def update
    seat = Seat.find params[:id]
    seat_params = params.permit(:category, :total_count, :price)
    if seat.update(seat_params)
      render json: seat
    else
      render json: seats.errors, status: :unprocessable_entity
    end
  end

  # DELETE /seats/1 or /seats/1.json
  def destroy
    seat = Seat.find params[:id]
    seat.destroy
    if seat.destroy
      head :ok
    else
      render json: seats.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seats
      seats = Seat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def seats_params
      params.permit(:category, :total_count, :price)
    end
end
