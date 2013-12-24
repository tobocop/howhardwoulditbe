module Plink
  class HeroPromotionRecord < ActiveRecord::Base
    self.table_name = 'hero_promotions'

    attr_accessor :user_ids_present

    has_many :hero_promotion_users, class_name: 'Plink::HeroPromotionUserRecord', foreign_key: 'user_id'

    attr_accessible :display_order, :image_url_one, :image_url_two, :is_active, :link_one,
      :link_two, :name, :same_tab_one, :same_tab_two, :show_linked_users, :show_non_linked_users,
      :title, :user_ids_present

    validates_presence_of :title, :image_url_one, :name

    validate :audience_selected
    validate :audience_by_card_status_or_user_ids

    def self.by_display_order
      order(:display_order)
    end

    def self.active
      where(is_active: true)
    end

    def self.by_user_id_and_linked(user_id, linked)
      linked_column_name = linked ? 'show_linked_users' : 'show_non_linked_users'

      Plink::HeroPromotionRecord.
        select('DISTINCT hero_promotions.*').
        joins('LEFT JOIN hero_promotion_users ON hero_promotions.id = hero_promotion_users.hero_promotion_id').
        where("#{linked_column_name} = ? OR (user_id = ? AND hero_promotion_users.id IS NOT NULL)", true, user_id)
    end

    def self.create_with_bulk_users(params={}, user_ids)
      params.delete(:user_ids)
      record_params = params.merge({user_ids_present: user_ids.present?})
      record = Plink::HeroPromotionRecord.create(record_params)

      if record.persisted? && user_ids
        file_path = "tmp/uploaded_files/hero_promotion_users_#{Time.zone.now.to_i}.csv"
        FileUtils.mv(user_ids.tempfile, File.join(Rails.root, file_path))

        Plink::HeroPromotionUserRecord.delay.bulk_insert(record.id, file_path)
      end

      record
    end

    def update_attributes_with_bulk_users(params={}, user_ids)
      params.delete(:user_ids)
      record_params = params.merge({user_ids_present: user_ids.present?})

      if updated = update_attributes(record_params) && user_ids
        Plink::HeroPromotionUserRecord.where(hero_promotion_id: id).delete_all

        file_path = "tmp/uploaded_files/hero_promotion_users_#{Time.zone.now.to_i}.csv"
        FileUtils.mv(user_ids.tempfile, File.join(Rails.root, file_path))

        Plink::HeroPromotionUserRecord.delay.bulk_insert(id, file_path)
      end

      updated
    end

    def user_count
      Plink::HeroPromotionUserRecord.joins('WITH (NOLOCK)').
        where(hero_promotion_id: id).count
    end

  private

    def audience_selected
      unless show_linked_users.present? || show_non_linked_users.present? || user_ids_present
        error = "Must select an audience"
        errors.add(:show_linked_users)
        errors.add(:show_non_linked_users)
        errors.add(:user_ids_present)
      end
    end

    def audience_by_card_status_or_user_ids
      card_status = show_linked_users.present? || show_non_linked_users.present?
      if card_status && user_ids_present
        error = "Cannot select audience by file and by linked card status"
        errors.add(:show_linked_users, error)
        errors.add(:show_non_linked_users, error)
        errors.add(:user_ids_present, error)
      end
    end
  end
end

