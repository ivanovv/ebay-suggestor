require 'json'

class Suggestion < ActiveRecord::Base

  belongs_to :keyword

  scope :real, lambda { where("value not in ('_items', '_sold_items')") }
  scope :search, lambda { where("value in ('_items', '_sold_items')") }
  scope :items, lambda { where("value = '_items'") }
  scope :sold_items, lambda { where("value = '_sold_items'") }



  def self.from_ebay_search(type, search_page)
    doc = Nokogiri::HTML(search_page)
    titles = doc.css('.ittl h3 a').map {|a| a.text.downcase}
    attributes = {
        :value => type,
        :variants => titles || []
    }
    new attributes
  end

  def self.from_ebay_suggestion ebay_suggestion
    raw_json = ebay_suggestion.match(/\._do\(([^\(]*)\)/)[1]
    json = JSON.parse raw_json
    attributes = {
        :value => json['prefix'],
        :variants => json['res']? json['res']['sug'] : []
    }
    new attributes
  end
end
