require 'spec_helper'

describe PlinkAdmin::UserQueryService do
  let(:user_query_service) { PlinkAdmin::UserQueryService }

  describe '.users_removed_for_103_errors' do
    subject(:user_query_service) { PlinkAdmin::UserQueryService }

    it 'makes calls to the data warehouse' do
      PlinkAdmin::Warehouse.connection.should_receive(:select_all).once.and_return([])

      user_query_service.users_removed_for_103_errors
    end
  end

end
