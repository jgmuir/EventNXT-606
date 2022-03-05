class Api::V1::EventsController < Api::V1::ApiController
  def index
  end
  
  def show
  end

  def create
    event = Event.create(events_params)
    render_valid(event)
  end

  def update
    event = Event.find params[:id]
    event.update_attributes(event_params)
    render_valid(event)
  end

  def destroy
    event = Event.find params[:id]
    event.destroy
  end

  private
  def events_params
    params.permit(:title, :address, :datetime, :image, 
        :x1, :y1, :x2, :y2, :description)
  end

  def render_valid(event)
    if event.valid?
      event.image.attach(params[:image])
      render json: {message: 'success'}
    else
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
