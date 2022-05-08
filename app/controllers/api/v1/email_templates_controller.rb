class Api::V1::EmailTemplatesController < Api::V1::ApiController
  def index
    templates = EmailTemplate.where(event_id: params[:event_id]).limit(params[:limit]).offset(params[:offset])
    render json: templates.map{ |template| with_attachments(template) }
  end

  def show
    template = EmailTemplate.find params[:id]
    render json: template
  end

  def create
    render json: {message: 'No bearer token'}, status: :forbidden and return unless current_user

    process_template_params
    par = template_params.to_h
    par[:user_id] = current_user.id 
    template = EmailTemplate.new par
    if template.save
      render json: with_attachments(template)
    else
      render json: template.errors, status: :unprocessable_entity
    end
  end

  def update
    unless process_template_params
      render json: { message: @message }, status: :unprocessable_entity
      return
    end
    template = EmailTemplate.find params[:id]
    if template.update(template_params)
      render json: template
    else
      render json: template.errors, status: :unprocessable_entity
    end
  end

  def destroy
    template = EmailTemplate.find params[:id]

    if params.has_key? :attachment_ids
      params[:attachment_ids].map! { |id| id.to_i }
      template.attachments.each { |attachment|
        attachment.purge if params[:attachment_ids].include? attachment.id
      }
    end

    unless params.has_key? :partial
      template.destroy
      unless template.destroy
        render json: template.errors, status: :unprocessable_entity
        return
      end
    end

    head :ok
  end

  private

  def with_attachments(model)
    attachments = model.attachments.map { |attachment|
      [attachment.id, url_for(attachment)]
    }.to_h if model.attachments.attached?
    model.as_json.merge({ attachments: attachments })
  end

  def process_template_params
    if params.has_key? :body
      params[:is_html] = params.has_key? :is_html
    else
      params.extract! :is_html
    end
    return true
  end

  def template_params
    params.permit(:name, :subject, :body, :is_html, :user_id, :event_id, attachments: [])
  end
end
