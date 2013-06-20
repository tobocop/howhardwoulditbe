require 'qa_spec_helper'

describe 'Signing in' do
  it 'lets the user sign in with Facebook'
  it 'tells the user there was a problem when they have an invalid Facebook login'

  it 'lets the user sign in with their Plink account'
  it 'tells the user their credentials are invalid when the email is not in our DB'
  it 'tells the user their credentials are invalid when the password is wrong'
  it 'tells the user that the email field is blank'
  it 'tells the user that the password field is blank'
end