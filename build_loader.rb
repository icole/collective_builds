require 'mongo'
require 'nokogiri'
require 'httparty'
require 'pry'

class BuildLoader

  def self.load_build(name, url)
    mongo_uri = ENV['MONGOLAB_URI']
    db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
    builds = Mongo::MongoClient.from_uri(mongo_uri).db(db_name).collection("builds")
    build = {name: name}
    build[:p3_url] = url
    build[:parts] = parse_parts(url)
    builds.insert(build)
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

          part[:price] = columns[3].text.gsub("\n", "").gsub("\t", "")
          parts << part
        end
      end
    end
    parts
  end
end
