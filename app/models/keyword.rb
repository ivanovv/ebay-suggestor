class Keyword < ActiveRecord::Base
  has_many :suggestions, :dependent => :destroy
  belongs_to :category
  validates :value, :presence => true

  def suggestion_count
    result = 0
    suggestions.real.each { |s| result += s.variants.count }
    result
  end

  def suggestions_count(type)
    result = {}
    seed_keyword = self.value.split(' ')
    suggestions_by_type = self.suggestions.send(type)
    suggestions_by_type.each do |s|
      s.variants.each do |v|
        keywords = v.split(/\s+|[,\+\-\(\)&!\/"\|\*\.]/).reject{|a| a.empty?}
        keywords = keywords - seed_keyword
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

  def all_keywords_count
    result = {}
    seed_keyword = self.value.split(' ')
    self.suggestions.each do |s|
      s.variants.each do |v|
        keywords = v.split(/\s+|[,\+\-\(\)&!\/"\|\*\.]/).reject{|a| a.empty?}
        keywords = keywords - seed_keyword
        keywords.each do |k|
          if result[k]
            result[k] = result[k] + 1
          else
            result[k] = 1
          end
        end
      end
    end
    Hash[result.sort_by {|k, v| -v}.first(100)]
  end

end
