class Route < ActiveRecord::Base
  attr_accessor :startpaint_id, :endpaint_id, :directions, :goroo_results
  
  belongs_to :startpoint, :class_name => "Venue", :foreign_key => "startpoint_id"
  belongs_to :endpoint, :class_name => "Venue", :foreign_key => "endpoint_id"
  
  validates :startpoint_id, :presence => true 
  validates :endpoint_id, :presence => true 
  
  after_create :get_xml
  
  def directions
     Nokogiri::XML(parsed_xml).xpath('//step').map do |i| 
      {'description' => i.xpath('html_instructions').text.html_safe, 
        'distance' => i.xpath('distance/text').text.html_safe
        }
        end 
  end
  
  
  def distance
    Nokogiri::XML(parsed_xml).xpath('/DirectionsResponse/route/leg/distance/text').text.html_safe
  end
  
  
  def parsed_xml
    GoogleDirections.new(startpoint.location, endpoint.location).xml
  end
  
  def agent
    agent = Mechanize.new 
  end
  
  def goroo_search_form
    goroo = agent.get("http://goroo.com/goroo/index.htm")
    form = goroo.form('tripPlan')
  end
  
  def goroo_interim_results
    goroo_search_form.origAddress = startpoint.location
    goroo_search_form.destAddress = endpoint.location
    results = agent.submit(goroo_search_form, goroo_search_form.buttons.first)
  end
  
  def goroo_results
    form = goroo_interim_results.form('tripPlan')
     results = agent.submit(form, form.buttons.first)
  end
  
  

private 
  def get_xml
    xml = GoogleDirections.new(startpoint.location, endpoint.location).xml
  end
  

end

 