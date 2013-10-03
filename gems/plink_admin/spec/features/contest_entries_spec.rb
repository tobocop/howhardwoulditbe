require 'spec_helper'

describe 'Contest entries' do
  let!(:contest) { create_contest }
  let!(:user)    { create_user(first_name: 'oldmanjumbo', email: 'jumbalaya@example.com') }
  let!(:entry1)  { create_entry(user_id: user.id, contest_id: contest.id, provider: 'twitter') }
  let!(:entry2)  { create_entry(user_id: user.id, contest_id: contest.id, provider: 'facebook') }

  before { create_admin(email: 'admin@example.com', password: 'pazzword') }

  it 'can be viewed for a specific user' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_on 'Contests'
    fill_in 'user_id', with: user.id
    click_on 'Search'

    page.should have_text user.id, count: 2
    page.should have_text user.emailAddress

    click_on 'Get contest stats'

    page.should have_text entry1.id
    page.should have_text entry2.id
    page.should have_text 'twitter'
    page.should have_text 'facebook'
  end

  it 'can be manually added by the admin' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_on 'Contests'
    fill_in 'user_id', with: user.id
    click_on 'Search'
    click_on 'Get contest stats'

    page.should have_text 'Multiplier: 1'

    fill_in 'number_of_entries', with: '7'
    click_on 'Submit'

    page.should have_text '7'
  end
end
