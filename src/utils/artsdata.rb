#!/usr/bin/env ruby

require 'sparql/client'
require 'rdf'
require 'shacl'
require 'rdf/turtle'

require 'linkeddata'
require 'json/ld'

class ArtsdataPipeline
  attr_accessor :sparql_client, :graph, :framed_graph, :report, :adid
  def initialize
    @sparql_client = SPARQL::Client.new("http://db.artsdata.ca/repositories/artsdata")
    @graph = RDF::Graph.new
    @adid = []
  end

  # loads triples from a file or SPARQL endpoint
  # parameter :file - path to local file
  # parameter :sparql, :limit, :graph
  def load(**args)
    return  @graph = @graph << RDF::Graph.load(args[:file]) if args[:file]

    if args[:graph]
      sparql = File.read(args[:sparql]).gsub("graph_placeholder",args[:graph])
    else
      sparql = File.read(args[:sparql])
    end
    if args[:limit]
      previous_count = 0
      i = 0
      loop do
        result = sparql_client.query(sparql.sub("limit 10 offset 0", "limit #{args[:limit]} offset #{i * args[:limit]}"))
        add_to_graph(result)
        if @graph.count == previous_count || i > 10
          puts "Done loading."
          puts @adid.inspect
          break
        end
        
        puts "Graph has #{@graph.count} triples"
        previous_count = @graph.count
        i += 1
      end
    else
      result = sparql_client.query(sparql)
      add_to_graph(result)
    end

    # dereference Arstdata IDs
    if @adid.count > 0
      uri_list = ""
      @adid.each { |uri| uri_list += " <#{uri}> " }
      sparql = File.read("./sparql/expand_artsdata_uris.sparql").gsub("<uri_list_placeholder>", uri_list)
      result = sparql_client.query(sparql)
      add_to_graph(result)
    end
    
  end


  def transform(sparql)
    @graph = @graph.query(SPARQL.parse(File.read(sparql), update: true))
  end

  def frame(frame)
    frame = JSON.parse(File.read(frame))
    input = JSON.parse(@graph.dump(:jsonld))
    @framed_graph = JSON::LD::API.frame(input, frame)
  end

  def dump(file)
    if @framed_graph
      File.write(file, @framed_graph.to_json)
    elsif @graph
      File.write(file, @graph.dump(:jsonld))
    end
  end

  def validate(shacl_file_or_url)
    shacl = SHACL.open(shacl_file_or_url)
    puts "Loaded SHACL #{shacl.class}"
    @report = shacl.execute(@graph)  
    puts "Conforms: #{@report.conform?}"
  end

  def report(file)
    File.write(file, @report)
  end

  private

  def add_to_graph(result)
    result.each_statement do |statement|
       # check if ADID and add to list for second step dereference
      @adid << statement.object.value if statement.object.uri? && statement.object.value.start_with?("http://kg.artsdata.ca/resource/")
      @adid.uniq!
      @graph << statement 
    end
  end
end