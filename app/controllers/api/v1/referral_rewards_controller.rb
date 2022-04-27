class Api::V1::ReferralRewardsController < Api::V1::ApiController
  def index
    rewards = query.limit(params[:limit]).offset(params[:offset])
    render json: rewards
  end

  def show
    reward = query.where(
      'referral_reward_id = :referral_reward_id',
      {referral_reward_id: params[:id]}
    ).first
    if reward
      render json: reward
    else
      render json: reward.errors(), status: :not_found
    end
  end

  def create
    reward = ReferralReward.new(event_id: params[:event_id], **reward_params.to_h)
    if reward.save
      render json: reward.to_json, status: :created
    else
      render json: reward.errors, status: :unprocessable_entity
    end
  end
  
  def update
    reward = ReferralReward.find(params[:id])
    if reward.update(reward_params)
      render json: reward.to_json, status: :ok
    else
      render json: reward.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    reward = ReferralReward.find(params[:id])
    reward.destroy
    head :ok
  end
  
  private

  def query
    ReferralReward.joins(:guest_referral_rewards)
                  .select('referral_rewards.id, reward, min_count, count(distinct(guest_id)) as qualified')
                  .group('referral_rewards.id')
                  .where(['count >= min_count and event_id = :event_id', {event_id: params[:event_id]}])
  end

  def reward_params
    params.permit(:reward, :min_count)
  end
end