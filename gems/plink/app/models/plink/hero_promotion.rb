module Plink
  class HeroPromotion

    attr_reader :title, :image_url, :show_linked_users, :show_non_linked_users

    def initialize(attributes)
      @title = attributes.fetch(:title)
      @image_url = attributes.fetch(:image_url)
      @show_linked_users = attributes.fetch(:show_linked_users)
      @show_non_linked_users = attributes.fetch(:show_non_linked_users)
    end
  end
end
