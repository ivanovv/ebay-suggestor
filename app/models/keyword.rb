class Keyword < ActiveRecord::Base
  has_many :suggestions
  belongs_to :category
end
