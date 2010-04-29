# This class is kind of big and ugly, but it's let's us 
# use a DSL to define transformers in subclasses
class Transformer
  
  def self.transform_with
    yield if block_given?
  end
  
  class << self
    attr_accessor :person_xpath_query
    attr_accessor :first_name_xpath_query
    attr_accessor :last_name_xpath_query
  end
  
  def self.person(person_xpath_query)
    self.person_xpath_query = person_xpath_query
    yield if block_given?
  end
  
  def self.first_name(first_name_xpath_query)
    self.first_name_xpath_query = first_name_xpath_query
  end
  
  def self.last_name(last_name_xpath_query)
    self.last_name_xpath_query = last_name_xpath_query
  end
  
  def self.inherited(transformer)
    (@transformers ||= []) << transformer
  end
  
  def self.transform(file_name)
    doc = Nokogiri::XML(open(file_name))
    @transformers.each do |transformer|
      people = transformer.new(doc).transform
      return people if people
    end
    nil
  end
  
  def initialize(file_name_or_doc)
    @doc = if file_name_or_doc.is_a?(Nokogiri::XML::Document)
      file_name_or_doc
    else
      Nokogiri::XML(open(file_name_or_doc))
    end
  end
  
  def transform
    person_nodes = @doc.xpath(self.class.person_xpath_query)
    unless person_nodes.empty?
      People.new(person_nodes.map do |node|
        Person.new(
          :first_name => node.xpath(self.class.first_name_xpath_query).first.content,
          :last_name => node.xpath(self.class.last_name_xpath_query).first.content)
      end).to_xml
    end
  end
end
