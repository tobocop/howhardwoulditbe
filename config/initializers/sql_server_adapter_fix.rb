class ActiveRecord::ConnectionAdapters::SQLServerAdapter
  def configure_connection
    do_execute "SET CONCAT_NULL_YIELDS_NULL ON"
  end
end