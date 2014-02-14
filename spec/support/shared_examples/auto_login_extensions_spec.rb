shared_examples_for(:auto_login_extensions) do
  let(:logged_in_user) { double(logged_in?: true, present?: true).as_null_object }
  let(:logged_out_user) { double(logged_in?: false, present?: false).as_null_object }

  before do
    controller.stub(:redirect_to)
    controller.stub(:sign_in_user)
  end

  it 'looks up the auto login token for a user' do
    controller.stub(:current_user).and_return(logged_in_user)
    AutoLoginService.should_receive(:find_by_user_token).
      with('asd').
      and_return(logged_in_user)

    controller.auto_login_user('asd', 'my_path')
  end

  it 'signs the user in if the user is found' do
    controller.stub(:current_user).and_return(logged_in_user)
    AutoLoginService.stub(:find_by_user_token).
      and_return(logged_in_user)
    controller.should_receive(:sign_in_user).with(logged_in_user)

    controller.auto_login_user('asd', 'my_path')
  end

  it 'redirects the user to the passed in path if the user is found' do
    controller.stub(:current_user).and_return(logged_in_user)
    AutoLoginService.stub(:find_by_user_token).
      and_return(logged_in_user)
    controller.should_receive(:redirect_to).with('my_path')

    controller.auto_login_user('asd', 'my_path')
  end

  it 'does not sign the user in if the user is not found' do
    controller.stub(:current_user).and_return(logged_out_user)
    AutoLoginService.stub(:find_by_user_token).
      and_return(logged_out_user)
    controller.should_not_receive(:sign_in_user)

    controller.auto_login_user('asd', 'my_path')
  end

  it 'redirects the user to the root_url with the notice the link has expired if the user is not found' do
    controller.stub(:current_user).and_return(logged_out_user)
    AutoLoginService.stub(:find_by_user_token).
      and_return(logged_out_user)
    controller.should_receive(:redirect_to).with(root_url, notice: 'Link expired.')

    controller.auto_login_user('asd', 'my_path')
  end
end

