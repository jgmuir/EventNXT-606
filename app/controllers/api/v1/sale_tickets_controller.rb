class Api::V1::SaleTicketsController < Api::V1::ApiController
    
    def index
      sales = SaleTicket.where(event_id: params[:event_id]).limit(params[:limit]).offset(params[:offset])
      render json: sales.map {|sale|  sale.as_json};
    end

    def count_all
      count = SaleTicket.where(event_id: params[:event_id]).count
      render json: count
    end
    
end