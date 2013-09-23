require 'spec_helper'

describe PlinkAdmin::ContestQueryService do
  describe '.get_statistics' do
    subject(:contest_query_service) { PlinkAdmin::ContestQueryService }

    it 'makes calls to the data warehouse' do
      PlinkAdmin::Warehouse.connection.should_receive(:select_all).twice.and_return([])

      contest_query_service.get_statistics(1)
    end
  end
end
