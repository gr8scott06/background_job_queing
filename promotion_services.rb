class PromotionServices

  include ReferralConstants
  include ::NewRelic::Agent::MethodTracer

  def initialize(current_user, ip, user_agent)
    @user = current_user
    @ip = Rails.env.production? ? ip : "98.209.124.38"
    @user_agent = CGI.escape(user_agent) #Aarki API
    @timestamp = Time.now.to_i
    @promotion_click_public_id = Time.now.to_i.to_s + "-" + SecureRandom.hex(4)
  end

  def get_all
    result = [get_fyber,get_aarki]
    # Parallel.map(["fyber","aarki"], in_threads: 2) do |platform|
    #   result << offer_platform_parser(platform)
    # end
    cpi_offers = result[0][:cpi_offers] + result[1][:cpi_offers]
    cpe_offers = result[0][:cpe_offers] + result[1][:cpe_offers]
    pending_offers = result[0][:pending_offers] + result[1][:pending_offers]
    unique_cpi_offers = parse_unique_offers(cpi_offers)
    unique_cpe_offers = parse_unique_offers(cpe_offers)
    return {cpi_offers: unique_cpi_offers, cpe_offers: unique_cpe_offers, pending_offers: pending_offers.first(8), promotion_click_public_id: @promotion_click_public_id}
  end

  ## Revised Attempt
  def revised_get_all
    fyber_response = Redis.current.setex("promotion_services/fyber_#{current_user.id}", 2.minutes, get_fyber))
    aarki_response = Redis.current.setex("promotion_services/aarki_#{current_user.id}", 2.minutes, get_aarki))
    cpi_offers = fyber_response[:cpi_offers] + aarki_response[:cpi_offers]
    ...
  end

  ...
  
end