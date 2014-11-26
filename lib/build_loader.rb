require 'mongo'
require 'nokogiri'
require 'httparty'
require 'pry'
require 'monetize'

class BuildLoader

  def self.load_build(params)
    mongo_uri = ENV['MONGOLAB_URI']
    db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
    builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
    if params[:url] && params[:url] != ""
      params[:parts] = parse_parts(params[:url])
      params[:total_price] = calculate_price(params[:parts])
    end
    params[:reviewed] = true
    builds.insert(params)
  end

  def self.calculate_price(parts)
    Money.use_i18n = false
    money = parts.map{|p| Monetize.parse(p[:price]).to_f}.inject(:+).to_money
    money.symbol + money.to_s
  end

  def self.parse_parts(url)
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)
    part_rows = doc.search("table[id*='partlist'] > tbody > tr")
    parts = []
    part_rows.each do |row|
      columns = row.children.search("td")
      if columns.count >= 4
        if columns[2].search("a").text && columns[2].search("a").text != ""
          part = {}
          #Component type
          part[:type] = columns[0].search("a").text

          #Part link and name
          part_link = columns[2].search("a")
          if part_link.attr("href")
            p3_name =  part_link.attr("href").value.gsub("/part/", "")
            asin = strip_asin_from_p3(p3_name)
            part[:p3_name] = p3_name
            part[:amazon_asin] =asin
            part[:amazon_url] = get_amazon_url(asin)
            part[:p3_url] = get_p3_url(name)
          end
          part[:name] = part_link.search("a").text

          #Pricing data
          if columns[3].attributes["colspan"] && columns[3].attributes["colspan"].text == "4"
            part[:price] = columns[4].text.gsub("\n", "").gsub("\t", "")
          else
            part[:price] = columns[7].text.gsub("\n", "").gsub("\t", "")
          end
          parts << part
        end
      end
    end
    parts
  end

  def self.strip_asin_from_p3(name)
    p3_base_url = "http://pcpartpicker.com/mr/amazon/"
    response = HTTParty.get(p3_base_url + name)
    amazon_url = response.request.last_uri.to_s
    amazon_url.gsub!("pcpapi-20", "")
    amazon_url.gsub!("/?tag=", "")
    amazon_url.split("/").last
  end

  def self.get_amazon_url(asin)
    "http://www.amazon.com/dp/#{asin}/?tag=aindexpc-20"
  end

  def self.get_p3_url(name)
    "http://pcpartpicker.com/part/" + name
  end

end
