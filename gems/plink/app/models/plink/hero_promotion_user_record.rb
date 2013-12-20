module Plink
  class HeroPromotionUserRecord < ActiveRecord::Base
    self.table_name = 'hero_promotion_users'

    belongs_to :hero_promotion, class_name: 'Plink::HeroPromotionRecord', foreign_key: 'hero_promotion_id'

    def self.bulk_insert(hero_promotion_id, user_ids_file_path)
      sql = "INSERT INTO hero_promotion_users (hero_promotion_id, user_id) VALUES "

      values = parse_from_file(user_ids_file_path).map do |user_id|
        "(#{hero_promotion_id}, #{user_id})"
      end

      values.each_slice(1000) do |sql_values|
        transaction do
          connection.execute "#{sql} #{sql_values.join(',')}"
        end
      end
    end

  private

    def self.parse_from_file(user_ids_file)
      result = []
      return result unless user_ids_file.present?

      File.open(Rails.root.join(user_ids_file), 'r') do |f|
        f.each_line do |line|
          result << line.strip.to_i
        end
      end

      result
    end
  end
end
