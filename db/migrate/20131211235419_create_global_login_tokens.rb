class CreateGlobalLoginTokens < ActiveRecord::Migration
  def up
    create_table :global_login_tokens do |t|
      t.datetime :expires_at
      t.string :token, limit: 60
      t.string :redirect_url

      t.timestamps
    end
  end

  def down
    drop_table :global_login_tokens
  end
end
