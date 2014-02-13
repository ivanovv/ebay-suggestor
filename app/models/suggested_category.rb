class SuggestedCategory < ActiveRecord::Base
  belongs_to :keyword
  validates :name, :presence => true
  validates :category_id, :presence => true


  def self.from_ebay_category(category)
    logger.info category
    parent_category = category[:category_parent_name]
    parent_category = parent_category.join('-->') if parent_category.is_a? Array
    attributes = {
        :name => category[:category_name],
        :parents => parent_category,
        :category_id => category[:category_id]
    }
    logger.info attributes
    new attributes
  end

  def to_s
    "#{self.parents}: #{self.name} (ID: #{self.category_id})"
  end

end
