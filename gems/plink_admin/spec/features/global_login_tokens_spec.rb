require 'spec_helper'

describe 'Global Login Tokens' do

  before do
    create_global_login_token(expires_at: 8.days.ago)
    create_global_login_token(expires_at: 3.days.ago)
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Global Login Tokens'

    within '.global_login_tokens-list' do
      within '.global_login_token-item:nth-of-type(1).expiring' do
        page.should have_content 3.days.ago.year
        page.should have_content 3.days.ago.month
        page.should have_content 3.days.ago.day
      end
    end

    click_on 'Create New Global Login Token'

    select 15.days.from_now.year, from: 'global_login_token[expires_at(1i)]'
    select 15.days.from_now.strftime("%B"), from: 'global_login_token[expires_at(2i)]'
    select 15.days.from_now.day, from: 'global_login_token[expires_at(3i)]'

    click_on 'Create'

    within '.alert-box.alert' do
      page.should have_content 'Expires at is invalid'
    end

    fill_in 'Redirect URL', with: 'http://example.com'
    select 7.days.from_now.year, from: 'global_login_token[expires_at(1i)]'
    select 7.days.from_now.strftime("%B"), from: 'global_login_token[expires_at(2i)]'
    select 7.days.from_now.day, from: 'global_login_token[expires_at(3i)]'

    click_on 'Create'

    within '.global_login_tokens-list' do
      within '.global_login_token-item:nth-of-type(2)' do
        page.should have_content 'http://example.com'
        page.should have_content 7.days.from_now.year
        page.should have_content 7.days.from_now.month
        page.should have_content 7.days.from_now.day
        page.should have_content 'some_kind_of_link'

        click_on 'Edit'
      end
    end

    page.should have_content 'Edit Global Login Token'

    fill_in 'Redirect URL', with: 'http://example.com/different'
    click_on 'Update'

    within '.global_login_tokens-list' do
      within '.global_login_token-item:nth-of-type(2)' do
        page.should have_content 'http://example.com/different'
      end
    end
  end
end
