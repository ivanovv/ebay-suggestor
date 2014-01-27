class AddSiteToKeyword < ActiveRecord::Migration
  def change
    add_column :keywords, :site_id, :integer
  end
end
