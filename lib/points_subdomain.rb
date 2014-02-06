class PointsSubdomain
  def self.matches?(request)
    request.subdomain != 'analytics'
  end
end
