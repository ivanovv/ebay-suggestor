require 'em-synchrony'
require 'em-synchrony/em-http'
require 'em-synchrony/fiber_iterator'

class KeywordsController < ApplicationController
  skip_before_filter :verify_authenticity_token
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
  end

  # GET /keywords/1/edit
  def edit
  end

  # POST /keywords
  # POST /keywords.json
  def create
    kw = keyword_params[:value].downcase.strip
    site_id = keyword_params[:site_id] || 0
    results = []
    @keyword = Keyword.find_by(:value => kw, :site_id => site_id)

    unless kw.empty? || @keyword != nil
      EM.synchrony do
        letters = ('a'..'z').to_a + ('0'..'9').to_a
        #letters = %w(a s)
        kw = URI.escape(kw)
        urls = letters.map { |l| "http://autosug.ebay.com/autosug?kwd=#{kw}%20#{l}&version=1279292363&_jgr=1&sId=#{site_id}&_ch=0&callback=GH_ac_callback" }
        items_url = "http://www.ebay.com/sch/i.html?_sacat=0&_from=R40&LH_BIN=1&_nkw=#{kw}&_ipg=200&rt=nc"
        sold_items_url = "http://www.ebay.com/sch/i.html?_sacat=0&_from=R40&LH_BIN=1&LH_Complete=1&LH_Sold=1&_nkw=#{kw}&_ipg=200&rt=nc"
        urls.unshift(items_url, sold_items_url)

        EM::Synchrony::FiberIterator.new(urls, 6).each do |url|
          http = EM::HttpRequest.new(url).get
          results.push [url, http.response]
        end
        EventMachine.stop
      end
    end

    unless @keyword
      @keyword = Keyword.new(keyword_params)
      @keyword.suggestions = results.map do |resp|
        if resp.first =~ /autosug/
          Suggestion.from_ebay_suggestion resp[1]
        else
          if resp.first =~ /LH_Complete/
            Suggestion.from_ebay_search('_sold_items', resp[1])
          else
            Suggestion.from_ebay_search('_items', resp[1])
          end
        end
      end
    end

    respond_to do |format|
      if @keyword.save
        format.html { render action: 'show' }
        format.json { render action: 'show', status: :created, location: @keyword }
      else
        format.html { render action: 'new' }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keywords/1
  # PATCH/PUT /keywords/1.json
  def update
    respond_to do |format|
      if @keyword.update(keyword_params)
        format.html { redirect_to @keyword, notice: 'Keyword was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1
  # DELETE /keywords/1.json
  def destroy
    @keyword.destroy
    respond_to do |format|
      format.html { redirect_to keywords_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_keyword
    @keyword = Keyword.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def keyword_params
    params.require(:keyword).permit(:value, :site_id)
  end
end
