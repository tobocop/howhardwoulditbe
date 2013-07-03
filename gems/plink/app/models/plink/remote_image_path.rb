module Plink
  class RemoteImagePath
    def self.url_for(image)
      Plink::Config.instance.image_base_url.sub(/\/$/, '') + '/' + image.sub(/^\//, '')
    end
  end
end