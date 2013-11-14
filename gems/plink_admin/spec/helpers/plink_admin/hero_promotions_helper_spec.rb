require 'spec_helper'

describe PlinkAdmin::HeroPromotionsHelper do
  describe '#determine_audience' do
    it 'returns "List of Users" when there are user_ids' do
      hero_promotion = double(audience_by_user_id?: true)

      helper.determine_audience(hero_promotion).should == 'List of Users'
    end

    it 'returns "All" when show linked users and show non-linked users are selected' do
      hero_promotion = double(audience_by_user_id?: nil, show_linked_users: true, show_non_linked_users: true)

      helper.determine_audience(hero_promotion).should == 'All'
    end

    it 'returns "Linked Users" when show_linked_users is selected' do
      hero_promotion = double(audience_by_user_id?: nil, show_linked_users: true, show_non_linked_users: false)

      helper.determine_audience(hero_promotion).should == 'Linked Users'
    end

    it 'returns "Non-Linked Users" when show_non_linked_users is selected' do
      hero_promotion = double(audience_by_user_id?: nil, show_linked_users: false, show_non_linked_users: true)

      helper.determine_audience(hero_promotion).should == 'Non-Linked Users'
    end

    it 'returns nil when no conditions are met' do
      hero_promotion = double(audience_by_user_id?: nil, show_linked_users: nil, show_non_linked_users: nil)

      helper.determine_audience(hero_promotion).should be_nil
    end
  end
end
