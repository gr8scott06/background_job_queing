class PromotionsController < ApplicationController
  before_action :mobile_traffic_only
  before_action :authenticate_user
  before_action :record_user_activity, only: [:index]
  include ReferralConstants
  include ::NewRelic::Agent::MethodTracer

  def index
    @social_sources = SocialSource.where(active: true).order(:position)
      .select {|s| !current_user.social_sources.include?(s)}
  end

  def promotion_service_request
    promotion_write = Redis.current
      .setex("promotion_services/#{current_user.id}", 2.minutes, Marshal.dump(PromotionServices.new(current_user, ip, user_agent).get_all))
    if promotion_write
      sort_cached_promotions
    else
      render layout: false #TODO: better response
    end
  end

  ## Revised Attempt
  def index_revised
    PromotionServices.new(current_user, ip, user_agent).delay.revised_get_all
  end

  #what key to poll for?

  ...
  
end