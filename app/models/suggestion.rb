class Suggestion < ActiveRecord::Base

  belongs_to :keyword

  def self.from_json json
    attributes = {
        :value => json['prefix'],
        :variants => json['res']['sug']
    }
    new attributes
  end
end
