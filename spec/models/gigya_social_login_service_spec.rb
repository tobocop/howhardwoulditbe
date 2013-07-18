require 'spec_helper'

describe GigyaSocialLoginService do
  let(:gigya_connection) { stub(:gigya_connection, delete_user: nil) }

  let(:service_params) do
    {
      UID: 'abc123',
      email: 'bob@example.com',
      firstName: 'Bob',
      gigya_connection: gigya_connection,
      photoURL: 'http://example.com/image',
      provider: 'dogster'
    }
  end

  describe '.initialize' do
    it 'assigns attributes on the service' do
      service = GigyaSocialLoginService.new(service_params)

      service.gigya_id.should == 'abc123'
      service.gigya_connection.should == gigya_connection
      service.email.should == 'bob@example.com'
      service.first_name.should == 'Bob'
      service.avatar_thumbnail_url.should == 'http://example.com/image'
      service.provider.should == 'dogster'
    end

    it 'raises if no gigya_connection is provided' do
      expect {
        service_params.delete(:gigya_connection)
        GigyaSocialLoginService.new(service_params)
      }.to raise_exception('key not found: :gigya_connection')
    end
  end

  describe '#sign_in_user' do
    context 'when gigya_user id is an integer' do

      before { Plink::UserService.any_instance.stub(:find_by_id).with(123) { user } }

      context 'when we find a user by id' do
        let(:user) { stub(avatar_thumbnail_url?: true, new_user?: false) }

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
          let(:user) { mock(avatar_thumbnail_url?: false, new_user?: false) }
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
        let(:user) { stub(avatar_thumbnail_url?: true, new_user?: false) }

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
          let(:user) { mock(avatar_thumbnail_url?: false, new_user?: false) }

          it 'copies the thumbnail url from the Gigya-provided info' do
            Plink::UserService.any_instance.stub(:find_by_id) { user }
            user.should_receive(:update_attributes).with(avatar_thumbnail_url: 'http://www.example.com/avatar.jpg')
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: '123', email: 'bob@example.com', photoURL: 'http://www.example.com/avatar.jpg'}).sign_in_user
          end
        end
      end

      context 'when we cannot find the user by email' do

        let(:user) { stub(id: 123, avatar_thumbnail_url?: true, new_user?: true) }

        before do
          Plink::UserCreationService.stub(:new) { stub(create_user: user) }
          Plink::Password.stub(:autogenerated) { stub(hashed_value: 'my-hashed-password', salt: 'my-salt') }
        end

        it 'creates a user via the UserCreationService' do
          Plink::UserCreationService.should_receive(:new).with(email: 'bob@example.com', first_name: 'Bob', password_hash: 'my-hashed-password', salt: 'my-salt', avatar_thumbnail_url: 'http://www.example.com/my-avatar.jpg')
          gigya_connection.stub(:notify_registration) { stub(:successful? => true) }
          gigya_social_login_service = GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: 'abc123', email: 'bob@example.com', firstName: 'Bob', photoURL: 'http://www.example.com/my-avatar.jpg', provider: 'twitter'})
          response = gigya_social_login_service.sign_in_user
          response.new_user.should be_true
          gigya_social_login_service.user.should == user
        end


        it 'should raise when user creation fails' do
          Plink::UserCreationService.should_receive(:new).with(email: 'bob@example.com', first_name: '', password_hash: 'my-hashed-password', salt: 'my-salt', avatar_thumbnail_url: nil) { raise(ActiveRecord::RecordInvalid, stub(errors: stub(full_messages: []))) }

          expect {
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: 'abc123', email: 'bob@example.com', firstName: '', avatar_thumbnail_url: nil}).sign_in_user
          }.to raise_exception(ActiveRecord::RecordInvalid)
        end

        it 'notifies Gigya of a user registration' do
          gigya_connection.should_receive(:notify_registration).with(site_user_id: 123, gigya_id: 'abc123') { stub(:successful? => true) }
          GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: 'abc123', email: 'bob@example.com', firstName: 'Bob'}).sign_in_user
        end

        it 'raises when Gigya user registration notification fails' do
          gigya_connection.stub(:notify_registration) { stub(:successful? => false) }

          expect {
            GigyaSocialLoginService.new({gigya_connection: gigya_connection, UID: 'abc123', email: 'bob@example.com', firstName: 'Bob'}).sign_in_user
          }.to raise_exception(GigyaSocialLoginService::GigyaNotificationError)
        end
      end
    end
  end
end