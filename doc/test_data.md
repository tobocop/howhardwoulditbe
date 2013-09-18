Generating Test Data
===================

1. SSH into the Rails Box

2. Open the rails console for the environment you're working in
  * `RAILS_ENV=review bundle exec rails c`

3. Require Plinks::ObjectCreationMethods
    * `> require "#{Rails.root}/gems/plink/lib/plink/test_helpers/object_creation_methods"`
    * `> include Plink::ObjectCreationMethods`

4. Call a creation method.
    * `> Plink::ObjectCreationMethods.create_reward(name: 'Amazon.com Gift Card', description: 'wolfman')`
    * `> Plink::ObjectCreationMethods.create_qualifying_award(currency_award_amount: 50000, dollar_award_amount: 500, user_id: 205, users_virtual_currency_id: 205, virtual_currency_id: 53)`

See /gems/plink/lib/plink/test_helpers/object_creation_methods.rb for implementation of these methods.
