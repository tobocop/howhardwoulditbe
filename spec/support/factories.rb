module FactoryTestHelpers
  def new_hero_promotion(options ={})
    defaults = {
        image_url: '/assets/test_image_tbd.jpg',
        title: 'Awesome Title',
        display_order: 1
    }
    HeroPromotion.new(defaults.merge(options))
  end

  def create_hero_promotion(options ={})
    hero_promotion = new_hero_promotion(options)
    hero_promotion.save!
    hero_promotion
  end
end
