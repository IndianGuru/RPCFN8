# Adam Lum's solution to RPCFN #8
# http://rubylearning.com/blog/2010/04/07/rpcfn-xml-transformer-8/

require 'rubygems'
require 'hpricot'
require 'rexml/document'
include REXML

# Get the source file(s) via the command line argument, didn't see anything
# in the challenge instructions detailing this step.
#ARGV.each do |filename| 
def transform filename
  doc = Hpricot.parse(File.read(filename))
  
  # Prepare the output file
  output = Document.new
  output << XMLDecl.new('1.0')
  people = output.add_element 'People'
  
  # Look for the first name element
  doc.search('//first_name | //first').each do |first_name_element|
    extra_siblings = []
    first_name = first_name_element.to_plain_text
    last_name = ""
    sibilng_elements = first_name_element.preceding_siblings + first_name_element.following_siblings
    # Look for the last name element, keep track of the other elements
    sibilng_elements.each do |sibling|
      if (sibling.pathname =~ /[last_name|last|surname]/)
        last_name = sibling.to_plain_text
      else
        extra_siblings << sibling
      end
    end
    # Add the people to the XML document
    person = people.add_element 'Person'
    person_name = person.add_element 'Name'
    person_first_name = person_name.add_element 'first'
    person_first_name.text = first_name
    person_last_name = person_name.add_element 'last'
    person_last_name.text = last_name
    extra_siblings.each do |sibling|
      temp_element = person.add_element sibling.pathname
      temp_element.text = sibling.to_plain_text
    end
  end
  
  # Output the result
  #f = File.new('result.xml', 'w')
  output   #.write(f, 1)
  #f.close
end