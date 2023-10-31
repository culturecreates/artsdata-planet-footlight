#!/usr/bin/env ruby

require_relative './utils/artsdata'

def FooltightPipeline()
  pipeline = ArtsdataPipeline.new
  dump = "../dump/export-csv-file_Event-bc8c86ea-9509-4f36-a6e9-cc7c9d8b5876.jsonld"
  
  puts "Loading data..."
  pipeline.load(file: dump)
  
  puts "Framing..."
  pipeline.frame( "../frame/footlight_frame.jsonld")
  
  puts "Saving framed JSON-LD..."
  pipeline.dump("../output/#{dump.split("/").last}")  
  
  puts "Validating shapes..."
  pipeline.validate("https://raw.githubusercontent.com/culturecreates/artsdata-data-model/master/shacl/shacl_artsdata.ttl")
  pipeline.report("../output/#{graph.split("/").last}.txt")
end

FooltightPipeline()