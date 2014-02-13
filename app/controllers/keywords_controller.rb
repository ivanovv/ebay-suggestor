require 'em-synchrony'
require 'em-synchrony/em-http'
require 'em-synchrony/fiber_iterator'

class KeywordsController < ApplicationController
  before_action :set_keyword, only: [:show, :edit, :update, :destroy]

  # GET /keywords
  # GET /keywords.json
  def index
    @keywords = Keyword.all
  end

  # GET /keywords/1
  # GET /keywords/1.json
  def show
  end

  # GET /keywords/new
  def new
    @keyword = Keyword.new
    if params.has_key? :show_tables
      session[:show_tables] = true
    end
  end

  # GET /keywords/1/edit
  def edit
  end

  # POST /keywords
  # POST /keywords.json
  def create
    @show_tables = session[:show_tables]
    kw = keyword_params[:value].downcase.strip
    site_id = keyword_params[:site_id] || 0

    @keyword = Keyword.find_by(:value => kw, :site_id => site_id)
    unless @keyword
      @keyword = Keyword.new(keyword_params)
      results = query_ebay(kw, site_id)
      @keyword.suggested_categories = get_suggested_categories(kw)
      @keyword.suggestions = results.map {|resp| Suggestion.from_ebay_response *resp }
    end
    logger.info @keyword.suggested_categories
    respond_to do |format|
      if @keyword.save
        format.html { render action: 'show' }
      else
        format.html { render action: 'new' }
      end
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_keyword
    @keyword = Keyword.find(params[:id])
  end

  def get_suggested_categories(query)
    categories = Ebayr.call(:GetSuggestedCategories, {:query => query})
    logger.info categories
    if categories[:ack] == 'Success'
      categories = categories[:suggested_category_array][:suggested_category]
      categories = [categories] unless categories.is_a? Array
      categories.first(3).map { |c| SuggestedCategory.from_ebay_category(c[:category]) }
    end
  end

  def query_ebay(kw, site_id)
    return [] if kw.empty?
    results = []
    EM.synchrony do
      letters = ('a'..'z').to_a + ('0'..'9').to_a
      #letters = %w(a s)
      kw = URI.escape(kw)
      urls = letters.map { |l| "http://autosug.ebay.com/autosug?kwd=#{kw}%20#{l}&version=1279292363&_jgr=1&sId=#{site_id}&_ch=0&callback=GH_ac_callback" }
      urls.unshift("http://www.ebay.com/sch/i.html?_sacat=0&_from=R40&LH_BIN=1&_nkw=#{kw}&_ipg=200&rt=nc")
      urls.unshift("http://www.ebay.com/sch/i.html?_sacat=0&_from=R40&LH_BIN=1&LH_Complete=1&LH_Sold=1&_nkw=#{kw}&_ipg=200&rt=nc")

      EM::Synchrony::FiberIterator.new(urls, 6).each do |url|
        http = EM::HttpRequest.new(url).get
        results.push [url, http.response]
      end
      EventMachine.stop
    end
    results
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def keyword_params
    params.require(:keyword).permit(:value, :site_id)
  end
end
