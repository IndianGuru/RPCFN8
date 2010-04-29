#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'builder'

# Specify xpath patterns for the different input formats
formats = {
  '/people/person'  =>  {
    :first => 'first_name',
    :last =>  'last_name'
  },
  '/address_book/contact'  =>  {
    :first  => 'name/first',
    :last =>  'name/last'
  },
  '/employees/employee'  =>  {
    :first  => 'first_name',
    :last =>  'surname'
  }
}

# Prepare input/output files
input = Nokogiri::XML.parse ARGF
output = Builder::XmlMarkup.new :target => STDOUT, :indent => 2

# Set xml version
output.instruct! :xml, :version=>"1.0", :encoding => nil

# Create root node
output.people do
  # Determine input format
  formats.each_pair do |matcher, patterns|
    # Find each person
    input.xpath(matcher).each do |match|
      # Create container nodes
      output.person do
        output.name do
          # Find each field
          patterns.each_pair do |field, pattern|
            # Create field node
            output.tag! field, match.xpath(pattern).text
          end
        end
      end
    end
  end
end
