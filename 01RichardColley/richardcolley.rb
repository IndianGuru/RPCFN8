=begin
  My submission for RFCN#8
  
  This program, reads stdin, or all files named as arguments, and outputs
  to stdout the transformed XML.
  
  Alternatively, the submission can be require'd and the Transformer
  class used in other applications.
  
  Transformation rules are (currently) at the end of this file in YAML.
  
  Rules can define name mappings, nesting, and whether they are optional
  in the input document.  The rule also indicates whether or not to copy
  the contents of input elements to output elements or not.
  
  I have created an additional "optional" element <age/> to test the
  extensibility of the rules.
=end

require 'yaml'
require 'nokogiri'

class Transformer
  def initialize rules=YAML::load(DATA) 
    @rules = rules
  end
  
  def transform indoc
    transform_recursively( @rules, indoc, Nokogiri::XML::Document.new )
  end
  
  private

  def transform_recursively( current_rule_node, current_input_node, current_output_node )
      current_rule_node.each do |symbol,tree|
        instructions, paths, child_rules = tree
        found_nodes = current_input_node.xpath( *paths )
        node_not_found = found_nodes.empty?
        found_nodes = [ current_input_node ] if node_not_found and instructions.include? :optional
        raise "Missing element <#{symbol}>" if node_not_found and not instructions.include? :optional
        raise "Too many <#{symbol}> elements" if found_nodes.count > 1 and instructions.include? :singular
        found_nodes.each do |found|
          new_node = current_output_node.add_child( Nokogiri::XML::Node.new(symbol.to_s, current_output_node) )
          new_node.content = found.content if instructions.include? :copy_content and not node_not_found
          transform_recursively( child_rules, found, new_node ) if child_rules
        end
      end
      current_output_node
  end
end



# simple test run
if __FILE__ == $PROGRAM_NAME
  transformer = Transformer.new
  for filename in ARGV
    begin
      open(filename) do |f|
        indoc = Nokogiri::XML(f)
        outdoc = transformer.transform(indoc)
        puts outdoc
      end
    rescue Exception => e
      $stderr.puts e
    end
  end
end


=begin
Define the rules used for the transformation.  Nested dictionaries
are used to indicate the output structure.  Each dictionary key/symbol
is used as the output xml tag name.

These could be read from a file, or placed elsewhere, but are here
now for convenience.  Currently in YAML format.

Format is a recursive structure:
  node = { symbol: [ [instructions], [xpath locations], {child nodes} ] }
where the following instructions are currently understood:
  :copy_content -> will copy the node content from input to output nodes
  :optional -> if we don't need to find this node in the input doc
                (note, we still create it in output doc)
  :singular -> this element can only appear once
                (note: the outer element can only appear once by definition)
=end
__END__
---
:people:
- []
- - //people
  - //address_book
  - //employees
- :person:
  - []
  - - person
    - contact
    - employee
  - :name:
    - - :optional
    - - name
    - :first:
      - - :copy_content
      - - first_name
        - first
      :last:
      - - :copy_content
      - - last_name
        - last
        - surname
    :age:
    - - :optional
      - :copy_content
    - - age
