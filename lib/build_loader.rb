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
    params[:parts] = parse_parts(params[:url])
    params[:total_price] = calculate_price(params[:parts])
    params[:reviewed] = false
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
          part = {type: columns[0].search("a").text}
          part[:name] = columns[2].search("a").text
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
end
