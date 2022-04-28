class Api::V1::EventsController < Api::V1::ApiController
  def index
    events = Event.where(user_id: params[:user_id]).limit(params[:limit]).offset(params[:offset])
    render json: events.map{ |event|
      image_url = event.image.attached? ? rails_storage_proxy_url(event.image) : ''
      event.as_json.merge({image_url: image_url})
    }
  end

  def show
    #@event = Event.find(params[:id])
    @event = Event.find(params[:id])
    #render json: {event: event}
  end

  def create
    #p = event_params
    #p[:last_modified] = Time.new
    event = Event.create(event_params)
    render_valid(@event)
    #render json: {params: event_params, event: event}
  end

  def update
    event = Event.find params[:id]
    event.update(event_params)
    render_valid(event)
  end

  def destroy
    event = Event.find params[:id]
    event.destroy
  end

  private
  def event_params
    params.permit(:title, :address, :datetime, :image, :description, :box_office_customers, :last_modified, :user_id)
        #:image, :box_office, :x1, :y1, :x2, :y2, :user_id)
  end

  def render_valid(event)
    @event = event
    if event.valid?
      event.image.attach(params[:image]) if params[:image].present?
      event.box_office.attach(params[:image]) if params[:box_office].present?
      #head :ok
      #render json: {event: event, params: params}
      params[:id] = event.id
      @event
    else
      render json: {errors: event.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
