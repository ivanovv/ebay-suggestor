class Keyword < ActiveRecord::Base
  has_many :suggestions
  belongs_to :category

  def suggestion_count
    result = 0
    suggestions.each { result +=  |s| s.variants.count }
  end
end
