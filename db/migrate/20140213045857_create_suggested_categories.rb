class CreateSuggestedCategories < ActiveRecord::Migration
  def change
    create_table :suggested_categories do |t|
      t.string :name
      t.string :parents
      t.integer :category_id
      t.references :keyword
    end
  end
end
