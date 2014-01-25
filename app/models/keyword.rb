class Keyword < ActiveRecord::Base
  has_many :suggestions
  belongs_to :category
  validates :value, :presence => true

  def suggestion_count
    result = 0
    suggestions.each { |s| result += s.variants.count }
    result
  end

  def suggestions_count
    result = {}
    seed_keyword = self.value.split(' ')
    suggestions.each do |s|
      s.variants.each do |v|
        keywords = v.split(' ') - seed_keyword
        keywords.each do |k|
          if result[k]
            result[k] = result[k] + 1
          else
            result[k] = 1
          end
        end
      end
    end
    Hash[result.sort_by {|k, v| -v}]
  end
end
