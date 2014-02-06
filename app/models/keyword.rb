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
    counter(self.suggestions.send(type), 10000)
  end

  def all_keywords_count
    counter(self.suggestions, 100)
  end

  def counter(iterator, record_count)
    result = {}
    seed_keyword = self.value.split(' ')
    iterator.each do |s|
      s.variants.each do |v|
        keywords = v.split(/\s+|[,\(\)!\/\*\[\]\{\};]/).reject{|a| a.empty?}
        keywords.map! {|k| k.sub /\.\.\.$/, ''}
        keywords = keywords - seed_keyword - %w(- + ( ) & ! / " | * .)
        keywords.each do |k|
          if result[k]
            result[k] = result[k] + 1
          else
            result[k] = 1
          end
        end
      end
    end
    Hash[result.sort_by {|k, v| -v}.first(record_count)]
  end

end
