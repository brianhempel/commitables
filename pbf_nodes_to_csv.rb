require "pbf_parser"
require "csv"
require "pry"

pbf = PbfParser.new(ARGV[0])

# http://download.geofabrik.de/north-america/us/michigan.html

# nodes_count = 0
# ways_count = 0
# relations_count = 0

print %w[id latitude longitude name type website timestamp].to_csv

loop do
  # nodes_count += pbf.data[:nodes].size
  # ways_count += pbf.data[:ways].size
  # relations_count += pbf.data[:relations].size

  # nodes = pbf.data[:nodes]
  # nodes.each do |node|
  #   if node[:tags]["name"]
  #     p node[:tags]
  #   end
  # end

  # ways = pbf.data[:ways]
  # ways.each do |way|
  #   if way[:tags]["name"]
  #     p way[:tags]
  #   end
  # end

  # relations = pbf.data[:relations]
  # relations.each do |relation|
  #   if relation[:tags]["name"]
  #     p relation[:tags]
  #   end
  # end

  nodes = pbf.data[:nodes]
  nodes.each do |node|
    if node[:tags]["name"]
      tags = node[:tags].reject { |k,v| v == "yes" }
      name = tags["name"]
      type = tags["amenity"] || tags["leisure"] || tags["place"]
      if !type && tags["shop"]
        type = "#{tags["shop"]}_shop"
      end
      type ||= tags["historic"] || tags["tourism"] || tags["power"] || tags["barrier"] || tags["man_made"] || tags["building"] || tags["highway"] || tags["aeroway"] || tags["office"] || tags["information"] || tags["boundary"]
      type ||= node[:tags].select { |k,v| v == "yes" }.keys.first
      website = tags["website"]
      timestamp = Time.at(node[:timestamp]/1000).utc.to_s

      print [node[:id], node[:lat], node[:lon], name, type, website, timestamp].to_csv
    end
  end

  break unless pbf.next
end

# nodes 10111336
# ways 721986
# relations 9249
