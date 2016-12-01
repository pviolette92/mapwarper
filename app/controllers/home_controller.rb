class HomeController < ApplicationController

  layout 'application'
  
  def index
    @html_title =  t('.title')

    @unwarped_maps = Map.where(:public => true, :status => [1,2,3]).order(:updated_at =>  :desc).limit(3).includes(:gcps)
    
    @year_min = Map.minimum(:issue_year).to_i - 1
    @year_max = Map.maximum(:issue_year).to_i + 1
    @year_min = 1600 if @year_min == -1
    @year_max = Time.now.year if @year_max == 1

    
    if user_signed_in?
      @my_maps = current_user.maps.order(:updated_at => :desc).limit(3)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @maps }
    end
  end
  
  # Searches for Maps and Layers across the titles and descriptions
  # Returns json (using jbuilder)
  # params 
  # query : string to search
  # per_page : limit number of records (optional)
  def search
    per_page = params[:per_page] || 50
    logger.debug per_page
    @results = PgSearch.multisearch(params[:query].to_s).limit(per_page.to_i)
  end
  
  private
  
  def get_news_feeds
    cache("news_feeds", :expires_in => 1.day.from_now) do 
      @feeds = RssParser.run("https://thinkwhere.wordpress.com/tag/mapwarper/feed/")
      @feeds = @feeds[:items][0..1]
    end
  end


end
