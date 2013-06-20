module FactoryTestHelpers
  def new_virtual_currency(options = {})
    defaults = {
        name: 'Plink Points',
        subdomain: 'www',
        exchange_rate: 100,
        site_name: 'Plink',
        singular_name: 'Plink Point'
    }

    VirtualCurrency.new(defaults.merge(options))
  end

  def create_virtual_currency(options = {})
    virtual_currency = new_virtual_currency(options)
    virtual_currency.save!
    virtual_currency
  end

  def new_user(orig_options = {})
    options = orig_options.dup

    plaintext_password = options.delete(:password)
    if plaintext_password.present?
      password = Password.new(unhashed_password: plaintext_password)
      options[:password_hash] = password.hashed_value
      options[:salt] = password.salt
    end


    defaults = {
        email: 'test@example.com',
        first_name: 'Joe',
        password_hash: 'D7913D231B862AEAD93FADAFB90A90E1A599F0FC08851414FD69C473242DAABD4E6DBD978FBEC1B33995CD2DA58DD1FEA660369E6AE962007162721E9C195192', # password: AplaiNTextstrIng55
        salt: '6BA943B9-E9E3-8E84-4EDCA75EE2ABA2A5'
    }

    User.new(defaults.merge(options))
  end

  def create_user(options = {})
    user = new_user(options)
    user.save!
    user
  end

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
