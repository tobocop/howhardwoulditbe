module Plink
  class RemoteImagePath
    def self.url_for(image)
      Plink::Config.instance.image_base_url.sub(/\/$/, '') + '/' + image.to_s.sub(/^\//, '')
    end
  end
end