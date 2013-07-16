module Plink
  class HeroPromotion

    attr_reader :title, :image_url

    def initialize(attributes)
      @title = attributes.fetch(:title)
      @image_url = attributes.fetch(:image_url)
    end
  end
end