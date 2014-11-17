require 'mongo'
require 'nokogiri'
require 'httparty'
require 'pry'

class BuildLoader

  def self.load_build(name, url)
    builds = Mongo::MongoClient.new("localhost", 27017).db("collective").collection("builds")
    build = {name: name}
    build[:parts] = parse_parts(url)
    builds.insert(build)
  end

  def self.parse_parts(url)
    response = HTTParty.get(url)
    doc = Nokogiri::HTML(response.body)
    part_rows = doc.search("table[id*='partlist'] > tbody > tr")
    parts = []
    part_rows.each do |row|
      links = row.children.search("a")
      if links.count >= 4
        part = {type: links[0].children.first.text}
        part[:name] = links[2].children.first.text
        part[:price] = links[3].children.first.text
        parts << part
      end
    end
    parts
  end
end
