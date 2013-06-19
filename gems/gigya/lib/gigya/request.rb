class Gigya
  class Request
    attr_accessor :signature_timestamp, :uid, :uid_signature

    def initialize(params)
      self.signature_timestamp = params[:signatureTimestamp]
      self.uid = params[:UID]
      self.uid_signature = params[:UIDSignature]
    end

    def valid_signature?
      has_recent_timestamp? && (computed_signature == uid_signature)
    end

    def has_recent_timestamp?
      (Time.now.to_i - self.signature_timestamp) <= 180
    end

    def computed_signature
      binary_key = Base64.decode64(secret)
      base_string = "#{self.signature_timestamp}_#{self.uid}"
      binary_signature = OpenSSL::HMAC.digest('sha1', binary_key, base_string)
      Base64.encode64(binary_signature).chomp
    end

    private

    def secret
      Config.instance.secret
    end
  end
end
