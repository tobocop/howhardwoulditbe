require 'spec_helper'

describe PreventMailInterceptor do
  it 'prevents mailing some recipients' do
    PreventMailInterceptor.stub(:deliver? => false)
    expect {
      deliver_mail
    }.not_to change(ActionMailer::Base.deliveries, :count)
  end

  it 'allows mailing other recipients' do
    PreventMailInterceptor.stub(:deliver? => true)
    expect {
      deliver_mail
    }.to change(ActionMailer::Base.deliveries, :count)
  end

  def deliver_mail
    ActionMailer::Base.mail(to: 'a@foo.com', from: 'b@foo.com').deliver
  end
end

describe PreventMailInterceptor, '.deliver?' do
  it 'is true for all recipients' do
    message = double(to: %w[user@plink.com])
    PreventMailInterceptor.deliver?(message).should be_true
  end
end

