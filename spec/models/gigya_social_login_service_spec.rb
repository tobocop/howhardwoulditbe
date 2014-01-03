require 'spec_helper'

describe GigyaSocialLoginService do
  let(:gigya_connection) { double(:gigya_connection, delete_user: nil, notify_registration: true) }

  let(:service_params) do
    {
      birthDay: '7',
      birthMonth: '2',
      birthYear: '1995',
      city: 'Denver',
      email: 'bob@example.com',
      firstName: 'Bob',
      gender: 'm',
      gigya_connection: gigya_connection,
      ip: '127.9.9.9',
      nickname: 'bobberson',
      photoURL: 'http://example.com/image',
      provider: 'dogster',
      state: 'CO',
      UID: 'abc123',
      user_agent: 'cool browser',
      zip: '80204'
    }
  end

  describe '.initialize' do
    it 'assigns attributes on the service' do
      service = GigyaSocialLoginService.new(service_params)

      service.gigya_id.should == 'abc123'
      service.gigya_connection.should == gigya_connection
      service.email.should == 'bob@example.com'
      service.first_name.should == 'Bob'
      service.nickname.should == 'bobberson'
      service.birthday.should == Time.zone.local(1995, 02, 07)
      service.gender.should == 'm'
      service.state.should == 'CO'
      service.city.should == 'Denver'
      service.zip.should == '80204'
      service.avatar_thumbnail_url.should == 'http://example.com/image'
      service.provider.should == 'dogster'
      service.ip.should == '127.9.9.9'
      service.user_agent.should == 'cool browser'
    end

    it 'raises if no gigya_connection is provided' do
      expect {
        service_params.delete(:gigya_connection)
        GigyaSocialLoginService.new(service_params)
      }.to raise_exception('key not found: :gigya_connection')
    end

    it 'assigns birthday to nil if the date is invalid' do
      service = GigyaSocialLoginService.new(service_params.except(:birthYear, :birthMonth, :birthDay))
      service.birthday.should be_nil
    end

    it 'assigns nickname to nil if it is passed in as blank' do
      service = GigyaSocialLoginService.new(service_params.merge(nickname:''))
      service.nickname.should be_nil
    end

    it 'assigns gender to nil if it is passed in as blank' do
      service = GigyaSocialLoginService.new(service_params.merge(gender:''))
      service.gender.should be_nil
    end

    it 'assigns state to nil if it is passed in as blank' do
      service = GigyaSocialLoginService.new(service_params.merge(state:''))
      service.state.should be_nil
    end

    it 'assigns city to nil if it is passed in as blank' do
      service = GigyaSocialLoginService.new(service_params.merge(city:''))
      service.city.should be_nil
    end

    it 'assigns zip to nil if it is passed in as blank' do
      service = GigyaSocialLoginService.new(service_params.merge(zip:''))
      service.zip.should be_nil
    end
  end

  describe '#sign_in_user' do
    context 'when gigya_user id is an integer' do
      before { Plink::UserService.any_instance.stub(:find_by_id).with(123) { user } }

      context 'when we find a user by id' do
        let(:user) { double(avatar_thumbnail_url?: true, new_user?: false) }

        it 'returns a successful response object' do
          response_object = GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123'}).sign_in_user
          response_object.success?.should be_true
        end

        it 'returns if a new user was created or not' do
          response_object = GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123'}).sign_in_user
          response_object.new_user?.should be_false
        end

        it 'returns the user' do
          gigya_social_login_service = GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123'})
          gigya_social_login_service.sign_in_user
          gigya_social_login_service.user.should == user
        end

        context 'when the user already has a thumbnail url' do
          it 'does not change the thumbnail' do
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123'}).sign_in_user
          end
        end

        context 'when the user does not have a thumbnail url' do
          let(:user) { double(avatar_thumbnail_url?: false, new_user?: false) }
          it 'copies the thumbnail url from the Gigya-provided info' do
            user.should_receive(:update_attributes).with(avatar_thumbnail_url: 'http://www.example.com/avatar.jpg')
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123', photoURL: 'http://www.example.com/avatar.jpg'}).sign_in_user
          end
        end
      end

      context 'when we cannot find a user by id' do
        it 'raises ActiveRecord::RecordNotFound' do
          Plink::UserService.any_instance.stub(:find_by_id).with(123) { raise ActiveRecord::RecordNotFound }
          expect {
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123'}).sign_in_user
          }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'when gigya_user id is not an integer' do
      context 'when we find the user by email' do
        let(:user) { double(avatar_thumbnail_url?: true, new_user?: false, id: 123) }

        before { Plink::UserService.any_instance.stub(:find_by_email).with('bob@example.com') { user } }

        context 'when registering in via twitter' do
          it 'does not auto sign in the user if the email already exists in the system' do
            service = GigyaSocialLoginService.new(service_params.merge(provider: 'twitter'))
            response = service.sign_in_user

            response.should_not be_success
            response.message.should == 'Sorry, that email has already been registered. Please use a different email.'
            service.user.should be_nil
          end

          it 'deletes the user from gigya' do
            service = GigyaSocialLoginService.new(service_params.merge(provider: 'twitter'))

            gigya_connection.should_receive(:delete_user).with('abc123')

            service.sign_in_user
          end
        end

        it 'returns that user' do
          gigya_social_login_service = GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: 'abc123', email: 'bob@example.com'})
          gigya_social_login_service.sign_in_user
          gigya_social_login_service.user.should == user
        end

        context 'when the user already has a thumbnail url' do
          it 'does not change the thumbnail' do
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: 'abc123', email: 'bob@example.com'}).sign_in_user
          end
        end

        context 'when the user does not have a thumbnail url' do
          let(:user) { double(avatar_thumbnail_url?: false, new_user?: false) }

          it 'copies the thumbnail url from the Gigya-provided info' do
            Plink::UserService.any_instance.stub(:find_by_id) { user }
            user.should_receive(:update_attributes).with(avatar_thumbnail_url: 'http://www.example.com/avatar.jpg')
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123', email: 'bob@example.com', photoURL: 'http://www.example.com/avatar.jpg'}).sign_in_user
          end
        end

        it 'notifies Gigya of a user registration' do
          notification_params = {site_user_id: 123, gigya_id: 'abc123'}
          gigya_connection.should_receive(:notify_registration).with(notification_params) {
            double(:successful? => true)
          }

          gigya_params = {
            gigya_connection: gigya_connection,
            UID: 'abc123',
            email: 'bob@example.com',
            firstName: 'Bob'
          }
          GigyaSocialLoginService.new(gigya_params).sign_in_user
        end
      end

      context 'when we cannot find the user by email' do
        let(:user) { double(id: 123, avatar_thumbnail_url?: true, new_user?: true, ip: '127.8.8.8') }
        let(:user_params) {
          {
            avatar_thumbnail_url: 'http://www.example.com/my-avatar.jpg',
            birthday: Time.zone.local(1995, 02, 07),
            city: 'Denver',
            email: 'bob@example.com',
            first_name: 'Bob',
            ip: '127.8.8.8',
            is_male: true,
            password_hash: 'my-hashed-password',
            provider: 'twitter',
            salt: 'my-salt',
            state: 'CO',
            username: 'bobberson',
            user_agent: 'my user agent',
            zip: '80204'
          }
        }
        let(:gigya_params) {
          {
            birthDay: '7',
            birthMonth: '2',
            birthYear: '1995',
            city: 'Denver',
            email: 'bob@example.com',
            firstName: 'Bob',
            gender: 'm',
            gigya_connection: gigya_connection,
            ip: '127.8.8.8',
            nickname: 'bobberson',
            photoURL: 'http://www.example.com/my-avatar.jpg',
            provider: 'twitter',
            state: 'CO',
            UID: 'abc123',
            user_agent: 'my user agent',
            zip: '80204'
          }
        }

        before do
          create_virtual_currency
          Plink::UserCreationService.stub(:new) { double(create_user: user, valid?: true) }
          Plink::Password.stub(:autogenerated) { double(hashed_value: 'my-hashed-password', salt: 'my-salt') }
        end

        it 'creates a user as a male via the UserCreationService when gender is m' do
          user_creation_double = double

          Plink::UserCreationService.should_receive(:new).with(user_params).and_return(user_creation_double)
          user_creation_double.should_receive(:valid?).and_return(true)
          user_creation_double.should_receive(:create_user).and_return(user)

          gigya_connection.stub(:notify_registration) { double(:successful? => true) }

          gigya_social_login_service = GigyaSocialLoginService.new(gigya_params)
          response = gigya_social_login_service.sign_in_user

          response.new_user.should be_true
          gigya_social_login_service.user.should == user
        end

        it 'creates a user as not a male via the UserCreationService when gender is f' do
          Plink::UserCreationService.should_receive(:new).with(user_params.merge(is_male: false))

          gigya_connection.stub(:notify_registration) { double(:successful? => true) }

          gigya_social_login_service = GigyaSocialLoginService.new(gigya_params.merge(gender: 'f'))
          response = gigya_social_login_service.sign_in_user

          response.new_user.should be_true
          gigya_social_login_service.user.should == user
        end

        it 'creates a that has nil is_male when gender is not m or f' do
          Plink::UserCreationService.should_receive(:new).with(user_params.merge(is_male: nil))

          gigya_connection.stub(:notify_registration) { double(:successful? => true) }

          gigya_social_login_service = GigyaSocialLoginService.new(gigya_params.merge(gender: 'unknown'))
          response = gigya_social_login_service.sign_in_user

          response.new_user.should be_true
          gigya_social_login_service.user.should == user
        end

        it 'should notify the user when user creation fails' do
          Plink::UserCreationService.unstub(:new)
          response = GigyaSocialLoginService.new(gigya_params.merge(firstName: "not'valid")).sign_in_user
          response.message.should == 'Sorry, your user registration failed. Please register through our form instead of twitter.'
        end

        it 'notifies Gigya of a user registration' do
          notification_params = {site_user_id: 123, gigya_id: 'abc123'}
          gigya_connection.should_receive(:notify_registration).with(notification_params) {
            double(:successful? => true)
          }

          GigyaSocialLoginService.new(gigya_params).sign_in_user
        end

        it 'raises when Gigya user registration notification fails' do
          gigya_connection.stub(:notify_registration) { double(:successful? => false) }

          expect {
            GigyaSocialLoginService.new(gigya_params).sign_in_user
          }.to raise_exception(GigyaSocialLoginService::GigyaNotificationError)
        end
      end
    end
  end
end
