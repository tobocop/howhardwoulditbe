require 'spec_helper'

describe Plink::HeroPromotion do
   let(:hero_promotion_attrs) do
    {
      title: 'Michael Jordan',
      image_url: '/mj_and_bb.jpg',
      link: 'www.google.com',
      show_linked_users: true,
      show_non_linked_users: false,
      user_ids: {}
    }
  end

  it 'populates its data from the given attributes' do
    hero_promotion = Plink::HeroPromotion.new(hero_promotion_attrs)

    hero_promotion.title.should == 'Michael Jordan'
    hero_promotion.image_url.should == '/mj_and_bb.jpg'
    hero_promotion.link.should == 'www.google.com'
    hero_promotion.show_linked_users.should == true
    hero_promotion.show_non_linked_users.should == false
    hero_promotion.user_ids.should be_empty
  end


  describe '#show_in_ui?' do
    context 'for a guest user' do
      it 'returns true if it should be shown to card linked and non-card linked users' do
        attrs = hero_promotion_attrs.merge(show_linked_users: true, show_non_linked_users: true)

        hero_promotion = Plink::HeroPromotion.new(attrs)

        hero_promotion.show_in_ui?(nil, false).should be_true
      end

      it 'returns false otherwise' do
        attrs = hero_promotion_attrs.merge(user_ids: {1 => true}, show_linked_users: false, show_non_linked_users: false)

        hero_promotion = Plink::HeroPromotion.new(attrs)

        hero_promotion.show_in_ui?(nil, false).should be_false
      end
    end
    context 'for a registered user' do
      context 'without a linked card' do
        it 'returns true if it should be shown to card non-card linked users' do
          attrs = hero_promotion_attrs.merge(show_linked_users: false, show_non_linked_users: true)
          hero_promotion = Plink::HeroPromotion.new(attrs)

          hero_promotion.show_in_ui?(1, false).should be_true
        end

        it 'returns false otherwise' do
          attrs = hero_promotion_attrs.merge(show_linked_users: false, show_non_linked_users: false)
          hero_promotion = Plink::HeroPromotion.new(attrs)

          hero_promotion.show_in_ui?(1, false).should be_false
        end
      end

      context 'with a linked card' do
        it 'returns false if the promotion should only be shown to non-linked users' do
          attrs = hero_promotion_attrs.merge(show_linked_users: false, show_non_linked_users: true)
          hero_promotion = Plink::HeroPromotion.new(attrs)

          hero_promotion.show_in_ui?(1, true).should be_false
        end

        it 'returns true if the promotion should be shown to linked users' do
          attrs = hero_promotion_attrs.merge(show_linked_users: true, show_non_linked_users: false)
          hero_promotion = Plink::HeroPromotion.new(attrs)

          hero_promotion.show_in_ui?(1, true).should be_true
        end

        it 'returns true if the given user is on the list of user ids' do
          attrs = hero_promotion_attrs.merge(show_linked_users: false, show_non_linked_users: false, user_ids: {1 => true})
          hero_promotion = Plink::HeroPromotion.new(attrs)

          hero_promotion.show_in_ui?(1, true).should be_true
        end

        it 'returns false if the given user is not on the list of user ids' do
          attrs = hero_promotion_attrs.merge(show_linked_users: false, show_non_linked_users: false, user_ids: {2 => true})
          hero_promotion = Plink::HeroPromotion.new(attrs)

          hero_promotion.show_in_ui?(1, true).should be_false
        end
      end
    end
  end
end
