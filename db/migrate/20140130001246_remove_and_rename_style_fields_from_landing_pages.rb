class RemoveAndRenameStyleFieldsFromLandingPages < ActiveRecord::Migration
  def up
    remove_column :landing_pages, :header_text_two_styles
    remove_column :landing_pages, :sub_header_text_two_styles

    remove_column :landing_pages, :detail_text_two_styles
    remove_column :landing_pages, :detail_text_three_styles
    remove_column :landing_pages, :detail_text_four_styles

    remove_column :landing_pages, :how_plink_works_one_text_two_styles
    remove_column :landing_pages, :how_plink_works_one_text_three_styles

    remove_column :landing_pages, :how_plink_works_two_text_two_styles
    remove_column :landing_pages, :how_plink_works_two_text_three_styles

    remove_column :landing_pages, :how_plink_works_three_text_two_styles
    remove_column :landing_pages, :how_plink_works_three_text_three_styles

    rename_column :landing_pages, :header_text_one_styles, :header_text_styles
    rename_column :landing_pages, :sub_header_text_one_styles, :sub_header_text_styles
    rename_column :landing_pages, :detail_text_one_styles, :detail_text_styles
    rename_column :landing_pages, :how_plink_works_one_text_one_styles, :how_plink_works_one_text_styles
    rename_column :landing_pages, :how_plink_works_two_text_one_styles, :how_plink_works_two_text_styles
    rename_column :landing_pages, :how_plink_works_three_text_one_styles, :how_plink_works_three_text_styles
  end

  def down
    add_column :landing_pages, :header_text_two_styles, :string
    add_column :landing_pages, :sub_header_text_two_styles, :string

    add_column :landing_pages, :detail_text_two_styles, :string
    add_column :landing_pages, :detail_text_three_styles, :string
    add_column :landing_pages, :detail_text_four_styles, :string

    add_column :landing_pages, :how_plink_works_one_text_two_styles, :string
    add_column :landing_pages, :how_plink_works_one_text_three_styles, :string

    add_column :landing_pages, :how_plink_works_two_text_two_styles, :string
    add_column :landing_pages, :how_plink_works_two_text_three_styles, :string

    add_column :landing_pages, :how_plink_works_three_text_two_styles, :string
    add_column :landing_pages, :how_plink_works_three_text_three_styles, :string

    rename_column :landing_pages, :header_text_styles, :header_text_one_styles
    rename_column :landing_pages, :sub_header_text_styles, :sub_header_text_one_styles
    rename_column :landing_pages, :detail_text_styles, :detail_text_one_styles
    rename_column :landing_pages, :how_plink_works_one_text_styles, :how_plink_works_one_text_one_styles
    rename_column :landing_pages, :how_plink_works_two_text_styles, :how_plink_works_two_text_one_styles
    rename_column :landing_pages, :how_plink_works_three_text_styles, :how_plink_works_three_text_one_styles
  end
end
