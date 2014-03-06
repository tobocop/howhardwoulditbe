require 'spec_helper'

describe AllPlinkNotificationMailer do
  describe 'tango_over_daily_limit' do
    it 'emails peeps@plink.com' do
      email = AllPlinkNotificationMailer.tango_over_daily_limit.deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['peeps@plink.com']
      email.from.should == ['info@plink.com']
      email.subject.should == 'ALERT:: Tango redemptions have exceeded $2500'

      [email.text_part, email.html_part].each do |part|
        body = part.body.to_s

        body.should =~ /Tango redemptions have exceeded \$2500 in the last 24 hrs and have been disabled./
      end
    end
  end
end
