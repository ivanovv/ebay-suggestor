require 'em-synchrony'
require "em-synchrony/em-http"
require "em-synchrony/fiber_iterator"
require 'json'

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
    #@suggestions = []
    #s = 'vjo.darwin.domain.finding.autofill.AutoFill._do({"prefix":"ipad d","dict":"0","res":{"sug":["ipad dock","ipad digitizer","ipad damaged","ipad docking station","ipad defender case","ipad dock speaker","ipad decal","ipad data cable","ipad defender","ipad dummy"],"categories":[[176970,"iPad/Tablet/eBook Accessories"]]}})'
    #json_string = s.match(/\._do\(([^\(]*)\)/)[1]
    #json = JSON.parse json_string
    #s = Suggestion.from_json json
    #@suggestions << s

    results = []

    EM.synchrony do
      multi = EM::Synchrony::Multi.new
      letters = %w(a b)
      kw = URI.escape(keyword_params[:value])
      urls = letters.map { |l| "http://autosug.ebay.com/autosug?kwd=#{kw}%20#{l}&version=1279292363&_jgr=1&sId=0&_ch=0&callback=GH_ac_callback" }

      #letters.each do |l|
      #  multi.add l.to_sym, EM::HttpRequest.new("http://autosug.ebay.com/autosug?kwd=#{kw}%20#{l}&version=1279292363&_jgr=1&sId=0&_ch=0&callback=GH_ac_callback").aget
      #end
      #data = multi.perform.responses[:callback].values.map(&:response)
      #binding.pry

      EM::Synchrony::FiberIterator.new(urls, 2).each do |url|
        resp = EM::HttpRequest.new(url).get
        results.push resp.response
      end
      puts "All done! Stopping event loop."
      EventMachine.stop
    end

    @keyword = Keyword.new(keyword_params)
    @suggestions = results.map do |resp|
      json_string = resp.match(/\._do\(([^\(]*)\)/)[1]
      json = JSON.parse json_string
      Suggestion.from_json json
    end

    respond_to do |format|
      format.html { render action: 'show' }
      format.json { render json: @keyword.errors, status: :unprocessable_entity }
    end

    #@keyword = Keyword.new(keyword_params)
    #
    #respond_to do |format|
    #  if @keyword.save
    #    format.html { redirect_to @keyword, notice: 'Keyword was successfully created.' }
    #    format.json { render action: 'show', status: :created, location: @keyword }
    #  else
    #    format.html { render action: 'new' }
    #    format.json { render json: @keyword.errors, status: :unprocessable_entity }
    #  end
    #end
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
    params.require(:keyword).permit(:value)
  end
end
