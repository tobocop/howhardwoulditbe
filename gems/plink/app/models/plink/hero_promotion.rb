module Plink
  class HeroPromotion

    attr_reader :id, :image_url_one, :image_url_two, :link_one, :link_two, :same_tab_one,
      :same_tab_two, :show_linked_users, :show_non_linked_users, :title

    def initialize(attributes)
      @id = attributes.fetch(:id)
      @image_url_one = attributes.fetch(:image_url_one)
      @image_url_two = attributes.fetch(:image_url_two)
      @link_one = attributes.fetch(:link_one)
      @link_two = attributes.fetch(:link_two)
      @same_tab_one = attributes.fetch(:same_tab_one)
      @same_tab_two = attributes.fetch(:same_tab_two)
      @show_linked_users = attributes.fetch(:show_linked_users)
      @show_non_linked_users = attributes.fetch(:show_non_linked_users)
      @title = attributes.fetch(:title)
    end

    def show_in_ui?(user_id, user_linked_card)
      if user_id.nil? && show_linked_users && show_non_linked_users
        true
      elsif user_linked_card && show_linked_users || !user_linked_card && show_non_linked_users
        true
      else
        false
      end
    end
  end
end
