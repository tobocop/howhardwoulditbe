class AddInterstitialTextToContestAdmin < ActiveRecord::Migration
  def change
    add_column :contests, :interstitial_title, :string
    add_column :contests, :interstitial_bold_text, :string
    add_column :contests, :interstitial_body_text, :string
    add_column :contests, :interstitial_share_button, :string
    add_column :contests, :interstitial_reg_link, :string
  end
end
