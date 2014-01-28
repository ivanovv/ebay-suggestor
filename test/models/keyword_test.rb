require 'test_helper'

class KeywordTest < ActiveSupport::TestCase
   test "suggestions_count" do
     k = Keyword.new(:value => 'ipad cover')
     s = Suggestion.new(:value => 'ipad cover w', :variants => ['ipad cover black', 'ipad cover white'])
     s2 = Suggestion.new(:value => 'ipad cover b', :variants => ['ipad cover yellow', 'ipad cover white with stand'])
     k.suggestions << [s, s2]
     k.save
     suggestions_count = k.suggestions_count(:real)
     puts suggestions_count
     assert suggestions_count['black'] == 1
     assert suggestions_count['white'] == 2
     #assert suggestions_count.first[0] == 'white'
     assert !suggestions_count['ipad']
     puts suggestions_count.first[0]
     puts suggestions_count.first[1]
     puts suggestions_count
   end
end
