# (c) Copyright 2010 Rémy Coutable. All Rights Reserved.
# RPCFN: XML Transformer (#8) : http://rubylearning.com/blog/2010/04/07/rpcfn-xml-transformer-8/
# 
# You can test XML transformation with:
# - files in the cloud (default): ruby xml_transformer.rb
# - local files: ruby xml_transformer.rb local
#
# My solutions works as follow:
# 1. It defines a hierarchical structure (as {:name => {:first, :last}, :birth => {:date, :place}...).
# 2. It parses the XML (file or url) file & store the recognized informations
#    according to this hierarchical structure.
# 3. It populates a new normalized XML document with the collected informations.
# 
# My solution skip the unrecognized nodes nested between 2 recognized nodes
# (i.e. in <name><useless><first_name>Rémy</first_name></useless></name>, the <useless> level will be ignored,
# and the useful informations will be stored as [{:name=>{:first=>'Rémy'}}]
# 
# For the moment it can only stores informations of 2-levels depth
# (i.e. :name=>{:first} but not :name=>{:first=>{:real, :fake}}.
# Though, with more work it could handle more depth levels.

require 'nokogiri'
require 'open-uri'

module Rymai
  
  class XmlTransformer
    
    attr_accessor :filename, :original_xml, :normalized_xml
    
    PARENT_INDEX_REGEX = /\D*(\[\d+\])*\D*\[(\d+)\]\D*/
    
    NAME_REGEX        = /name/
    BIRTH_REGEX       = /birth/
    ADDRESS_REGEX     = /address/
    FATHER_REGEX      = /father/
    MOTHER_REGEX      = /mother/
    
    FIRST_REGEX       = /_?first_?/
    LAST_REGEX        = /_?(sur|last|family)_?/
    
    PLACE_REGEX       = /_?place_?/
    DATE_REGEX        = /_?date_?/
    
    STREET_REGEX      = /_?street_?/
    NUMBER_REGEX      = /_?number_?/
    POSTAL_CODE_REGEX = /_?postal_?code_?/
    CITY_REGEX        = /_?city_?/
    COUNTRY_REGEX     = /_?country_?/
    
    REGEX_MAPPING = {
      :name        => NAME_REGEX,
      :birth       => BIRTH_REGEX,
      :address     => ADDRESS_REGEX,
      :first       => FIRST_REGEX,
      :last        => LAST_REGEX,
      :place       => PLACE_REGEX,
      :date        => DATE_REGEX,
      :street      => STREET_REGEX,
      :number      => NUMBER_REGEX,
      :postal_code => POSTAL_CODE_REGEX,
      :city        => CITY_REGEX,
      :country     => COUNTRY_REGEX
    }
    
    HIERARCHY = {
      :name => [:first, :last],
      :birth => [:place, :date],
      :address => [:street, :number, :postal_code, :city, :country],
    }
    
    def initialize(filename)
      @filename = filename
      
      file_content = if @filename =~ /https?:\/\//
        open(@filename)
      elsif File.file?(@filename)
        File.new(@filename)
      else
        print "\n!Warning! #{filename} is not a readable file!\n"
      end
      
      @original_xml   = Nokogiri::XML::Document.parse(file_content) if file_content
      @normalized_xml = "\nNo normalized XML yet\n"
    end
    
    def transform
      return false unless @original_xml
      
      @normalized_array = []
      
      explore(@original_xml.root.path)
      
      @normalized_xml = Nokogiri::XML::Document.new
      @normalized_xml.encoding = 'UTF-8'
      
      @normalized_xml << @normalized_xml.create_element('people') do |people_node|
      @normalized_array.each do |person_infos|
        people_node << @normalized_xml.create_element('person') do |person_node|
        person_infos.each do |level_1_name, level_2_infos|
          person_node << @normalized_xml.create_element(level_1_name.to_s) do |level1_node|
          level_2_infos.each do |level_2_name, text|
            if level_2_name == :text
              level1_node << @normalized_xml.create_text_node(text)
            else
              level1_node << @normalized_xml.create_element(level_2_name.to_s) do |level2_node|
                level2_node << @normalized_xml.create_text_node(text)
              end
            end
          end
          end
        end
        end
      end
      end
      
      true
    end
    
    def to_s
      @normalized_xml.to_s
    end
    
  private
    
    # Recursive method that parse the xml given x_path
    # and save formatted informations in the normalized_array instance variable.
    def explore(x_path)
      @original_xml.xpath(x_path).each do |data|
        data.children.each do |node|
          
          if node.element?
            level_1 = Rymai::XmlTransformer.get_level_1(node)
            if PARENT_INDEX_REGEX.match(node.parent.path)
              if level_1 && level_2 = Rymai::XmlTransformer.get_level_2(level_1, node)
                ((@normalized_array[$2.to_i - 1]||={})[level_1]||={})[level_2] = node.child.text
              end
            end
            explore(node.path)
          end
          
        end
      end
    end
    
    # Recursive method that return the normalized level 1 node name corresponding to the node given.
    # This method search in the ancestors of the node if necessary.
    # Return nil if no level 1 node is found
    # 
    # For example, if the node given has the name 'first_name', then this method will return 'name'.
    # 'name' is the normaized level 1 node name for a person's name informations
    # (and 'first' is the level 2 for first name information)
    def self.get_level_1(node)
      if level_1 = detect_level_1(node)
        return level_1
      else
        node.ancestors.each do |ancestor|
          get_level_1(ancestor)
        end
        nil
      end
    end
    
    # Given a +level_1+ node name, this method return the normalized level 2 node name
    # corresponding to the +node+ given.
    def self.get_level_2(level_1, node)
      HIERARCHY[level_1].each do |node_name|
        return node_name if REGEX_MAPPING[node_name].match(node.name)
      end
      nil
    end
    
    # Return the normalized level 1 node name corresponding to the +node+ given.
    def self.detect_level_1(node)
      HIERARCHY.keys.each do |father_node|
        return father_node if REGEX_MAPPING[father_node].match(node.name)
      end
      # We didn't find a level 1 node, let's try with the level 2 nodes...
      # If we find, we set the level 1 node corresponding to the found level 2 (as set in HIERARCHY_MAPPING).
      HIERARCHY.each do |father_node, sons_nodes|
        sons_nodes.each do |node_name|
          return father_node if REGEX_MAPPING[node_name].match(node.name)
        end
      end
      nil
    end
    
  end
  
end

=begin
XML_FILES_IDS_IN_THE_CLOUD = %w[UMB US3 UaY VIm].map{ |id| "http://cl.ly/#{id}/content" }
XML_LOCAL_FILES_NAMES = %w[source1.xml source2.xml source3.xml source_custom.xml]
SOURCE = ARGV[0] && ARGV[0].downcase == "local" ? XML_LOCAL_FILES_NAMES : XML_FILES_IDS_IN_THE_CLOUD

print "\nTransforming XML sources #{SOURCE == XML_FILES_IDS_IN_THE_CLOUD ? 'from the cloud' : 'locally'}:\n"

# Tests Rymai::XmlTransformer with the xml source files (including the custom one with additional fields)
SOURCE.each do |filename|
  transformer = Rymai::XmlTransformer.new(filename)
  if transformer.transform
    print "\n#{filename} after transformation:\n"
    print transformer.to_s
  end
end
=end