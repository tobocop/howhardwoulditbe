require 'spec_helper'

describe 'Sendgrid Events API' do
  let!(:events) {
    '[
      {
        "email": "dropped@example.com",
        "smtp-id": "<4FB29F5D.5080404@sendgrid.com>",
        "timestamp": 1386636115,
        "reason": "Invalid",
        "event": "dropped",
        "category": [
          "category1",
          "category2",
          "category3"
        ]
      },
      {
        "status": "5.1.1",
        "sg_event_id": "X_C_clhwSIi4EStEpol-SQ",
        "reason": "550 5.1.1 The email account that you tried to reach does not exist. Please try double-checking the recipient\'s email address for typos or unnecessary spaces. Learn more at http: \/\/support.google.com\/mail\/bin\/answer.py?answer=6596 do3si8775385pbc.262 - gsmtp ",
        "event": "bounce",
        "email": "bounced@example.com",
        "timestamp": 1386637483,
        "smtp-id": "<142da08cd6e.5e4a.310b89@localhost.localdomain>",
        "type": "bounce",
        "category": [
          "category1",
          "category2",
          "category3"
        ]
      },
      {
        "sg_event_id": "X_C_clhwSIi4EStEpol-SG",
        "event": "spamreport",
        "email": "spamreport@example.com",
        "timestamp": 1386637483,
        "smtp-id": "<142da08cd6e.5e4a.310b89@localhost.localdomain>",
        "category": [
          "category1",
          "category2",
          "category3"
        ]
      },
      {
        "email": "processed@example.com",
        "sg_event_id": "VzcPxPv7SdWvUugt-xKymw",
        "sg_message_id": "142d9f3f351.7618.254f56.filter-147.22649.52A663508.0",
        "timestamp": 1386636112,
        "smtp-id": "<142d9f3f351.7618.254f56@sendgrid.com>",
        "event": "processed",
        "category": [
          "category1",
          "category2",
          "category3"
        ]
      }
    ]'
  }
  let!(:dropped_user) { create_user(email: 'dropped@example.com') }
  let!(:bounced_user) { create_user(email: 'bounced@example.com') }
  let!(:spam_user) { create_user(email: 'spamreport@example.com') }
  let!(:processed_user) { create_user(email: 'processed@example.com') }

  it 'processes sendgrid events and unsubscribes drops, bounces, unsubscribes and spam reports' do
    post '/v1/sendgrid_events', _json: events

    response.should be_success

    dropped_user.reload.is_subscribed.should be_false
    bounced_user.reload.is_subscribed.should be_false
    spam_user.reload.is_subscribed.should be_false

    processed_user.reload.is_subscribed.should be_true
  end
end