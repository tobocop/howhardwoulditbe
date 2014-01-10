class IntuitInstitutionRequest
  def self.institution_data(user_id, intuit_institution_id)
    Intuit::Request.new(user_id).institution_data(intuit_institution_id)
  end
end
