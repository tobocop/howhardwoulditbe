class AnalyticsSubdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain == 'analytics'
  end
end
