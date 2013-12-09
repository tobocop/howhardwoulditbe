module Plink
  class HeroPromotion

    attr_reader :id, :image_url, :image_url_right, :link, :link_right, :same_tab_one,
      :same_tab_two, :show_linked_users, :show_non_linked_users, :title, :user_ids

    def initialize(attributes)
      @id = attributes.fetch(:id)
      @image_url = attributes.fetch(:image_url)
      @image_url_right = attributes.fetch(:image_url_right)
      @link = attributes.fetch(:link)
      @link_right = attributes.fetch(:link_right)
      @same_tab_one = attributes.fetch(:same_tab_one)
      @same_tab_two = attributes.fetch(:same_tab_two)
      @show_linked_users = attributes.fetch(:show_linked_users)
      @show_non_linked_users = attributes.fetch(:show_non_linked_users)
      @title = attributes.fetch(:title)
      @user_ids = attributes.fetch(:user_ids)
    end

    def show_in_ui?(user_id, user_linked_card)
      if user_id.nil? && show_linked_users && show_non_linked_users
        true
      elsif user_linked_card && show_linked_users || !user_linked_card && show_non_linked_users
        true
      elsif user_ids.present? && user_ids[user_id]
        true
      else
        false
      end
    end
  end
end
