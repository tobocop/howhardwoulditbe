require 'spec_helper'

describe 'Affiliates' do
  let(:user) { create_user }
  let(:award_type) { create_award_type(dollar_amount: 3.12) }
  let!(:receipt_promotion) { create_receipt_promotion(award_type_id: award_type.id, name: 'best promo') }

  before do
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    virtual_currency = create_virtual_currency
    users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
    receipt_submission = create_receipt_submission(
      body: 'some body',
      from_address: 'testing@example.com',
      subject: 'pepsi promotion',
      user_id: user.id,
      queue: 1
    )

    create_receipt_submission_attachment(receipt_submission_id: receipt_submission.id, url: 'http://example.com/image-one.jpg')
    create_receipt_submission_attachment(receipt_submission_id: receipt_submission.id, url: 'http://example.com/pdf.pdf')

    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be approved or denied by admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Receipt Submissions'

    click_on 'Process Queue 1 (1 submissions)'

    page.should have_content '1 submissions to process'
    page.should have_content 'some body'
    page.should have_content 'testing@example.com'
    page.should have_content '23'
    page.should have_content 'pepsi promotion'
    page.should have_css "img[src='http://example.com/image-one.jpg']"
    page.should have_css "a[href='http://example.com/pdf.pdf']"

    choose 'Approve'

    select "best promo - $3.12 (#{receipt_promotion.id})"

    click_on 'Process'

    page.should have_content 'Submission updated and user awarded'
    page.should have_content 'Queue Complete'

    user.reload.current_balance.should == 3.12

  end
end
