class IntuitInstitutionRequest
  def self.institution_data(user_id, intuit_institution_id)
    Aggcat.scope(user_id).institution(intuit_institution_id)
  end
end
