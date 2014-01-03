module Plink
  class UsersInstitutionService
    def self.users_institution_registered?(hash_check, institution_id, user_id)
      duplicates = Plink::UsersInstitutionRecord.duplicates(hash_check, institution_id, user_id)

      duplicates.each do |duplicate|
        Plink::DuplicateRegistrationAttemptRecord.create({
          existing_users_institution_id: duplicate.id,
          user_id: user_id
        })
      end

      duplicates.length > 0
    end
  end
end


