module Plink
  class HeroPromotion

    attr_reader :title, :image_url, :link, :show_linked_users, :show_non_linked_users,
      :user_ids

    def initialize(attributes)
      @title = attributes.fetch(:title)
      @image_url = attributes.fetch(:image_url)
      @link = attributes.fetch(:link)
      @show_linked_users = attributes.fetch(:show_linked_users)
      @show_non_linked_users = attributes.fetch(:show_non_linked_users)
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
