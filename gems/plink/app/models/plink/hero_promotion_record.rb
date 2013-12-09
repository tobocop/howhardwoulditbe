module Plink
  class HeroPromotionRecord < ActiveRecord::Base
    self.table_name = 'hero_promotions'

    serialize :user_ids, Hash

    attr_accessible :display_order, :image_url_one, :image_url_two, :is_active, :link_one,
      :link_two, :name, :same_tab_one, :same_tab_two, :show_linked_users, :show_non_linked_users,
      :title, :user_ids

    validates_presence_of :title, :image_url_one, :name

    validate :audience_selected
    validate :audience_by_card_status_or_user_ids

    def self.by_display_order
      order(:display_order)
    end

    def self.active
      where(is_active: true)
    end

    def audience_by_user_id?
      user_ids.present?
    end

  private

    def audience_selected
      unless show_linked_users.present? || show_non_linked_users.present? || user_ids.present?
        error = "Must select an audience"
        errors.add(:show_linked_users)
        errors.add(:show_non_linked_users)
        errors.add(:user_ids)
      end
    end

    def audience_by_card_status_or_user_ids
      card_status = show_linked_users.present? || show_non_linked_users.present?
      if card_status && user_ids.present?
        error = "Cannot select audience by file and by linked card status"
        errors.add(:show_linked_users, error)
        errors.add(:show_non_linked_users, error)
        errors.add(:user_ids, error)
      end
    end
  end
end

