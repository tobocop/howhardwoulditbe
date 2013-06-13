class Password
  attr_writer :unhashed_password
  attr_accessor :salt

  def initialize(options = {})
    self.unhashed_password = options.fetch(:unhashed_password)
    self.salt = options[:salt] || SecureRandom.uuid
  end

    def hashed_value
      salted_password = ""

      # TODO: This is not hashing and rehashing the password 1000 times.
      # This is only iterating and rehashing an identical string over and over to increase the work done.
      1000.times do
        salted_password = (Digest::SHA512.new << (salt + @unhashed_password)).hexdigest.upcase
      end

      salted_password
  end
end