p 'Creating VirtualCurrency'
VirtualCurrency.create(name: "Plink Points", subdomain: "www", exchange_rate: 100, site_name: "Plink", singular_name: "Plink Point")

p 'Creating HeroPromotions'
HeroPromotion.create(image_url:'/assets/hero-gallery/bk_2.jpg', title:'Get Double Points at Burger King', display_order:1)
HeroPromotion.create(image_url:'/assets/hero-gallery/TacoBell_2.jpg', title:'New Partner - Taco Bell', display_order:2)
HeroPromotion.create(image_url:'/assets/hero-gallery/7eleven_2.jpg', title:'7-Eleven = AMAZING HOTDOGS', display_order:3)