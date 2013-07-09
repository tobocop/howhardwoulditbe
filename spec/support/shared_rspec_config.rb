class SharedRSpecConfig
  def self.setup(config)

    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.infer_base_class_for_anonymous_controllers = false
    config.order = "random"
    config.verbose_retry = true

    config.include(FactoryTestHelpers)
    config.include(FeatureSpecHelper, type: :feature)
    config.include(UserActions, type: :feature)
    config.include(Plink::ObjectCreationMethods)

    config.use_transactional_fixtures = false

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      ActionMailer::Base.deliveries.clear
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:each, type: :feature) do
      delete_users_from_gigya
    end
  end
end