# RPCFN 8: XML Transformer
# Benoit Daloze
# Ruby 1.9.2 >= r25032 (Enumerable#slice_before)
#
# This solution use my personnal TreeNode class
# My TreeNode class acts as an "inside" Tree, being a module extending the object that become a TreeNode 
# Sorry if that class is long, it's not the main work for this challenge, and the API is easy, so just keep in mind:
#   obj.extend TreeNode # make obj a TreeNode
#   obj << other # add other as a child
#   obj >> other # remove other from his parent obj
#
# The code is kind of speaking by itself, so that's why I did not comment it much
#
# Enjoy!

require "nokogiri"
require_relative "tree"
require 'backports'

DIR = "../xmlfiles"
TARGET = "result"

class Array
  def only
    raise IndexError, "Array#only called on non-single-element array (size=#{size}): #{self}" unless size == 1
    first
  end
end

class XNode < String
  def to_s
    "<#{super}>"
  end
end
class XText < String
end

class Nokogiri::XML::Node
  def to_a
    children.each_with_object([]) { |child, a|
      case child
      when Nokogiri::XML::Text
        a << XText.new(child.text) unless child.to_s.match(/\A\s+\z/)
      when Nokogiri::XML::Node
        a << XNode.new(child.name) << child.to_a
      end
    }
  end
end

module TreeNode
  def to_nokogiri_node(doc)
    node = Nokogiri::XML::Node.new(self, doc)
    children.each { |c|
      case c
      when XNode
        node << c.to_nokogiri_node(doc)
      when XText
        node << Nokogiri::XML::Text.new(c, doc)
      end
    }
    node
  end
  def to_nokogiri_doc
    Nokogiri::XML::Document.new.tap { |doc| doc << self.root.to_nokogiri_node(doc) }
  end
end

class XMLTransformer
  ALIASES = { "surname" => "last_name" }
  attr_reader :tree, :result_tree

  def initialize(file, result = "#{DIR}/#{TARGET}.xml")
    @result_tree = TreeNode.from_ary Nokogiri::XML(IO.read(result)).to_a
    @structure = result_tree.linearize.reduce(:&).map(&:dup)
    @tree = TreeNode.from_ary Nokogiri::XML(IO.read(file)).to_a
  end

  def to_s
    @tree.show_simple
  end

  def aliases
    tree.all.select { |n| n.depth == 2 }.each { |n|
      ALIASES.keys.each { |to_replace|
        n.replace(ALIASES[to_replace]) if n == to_replace
      }
    }
  end

  def nesting
    # last_name => name > last
    node_nested = @tree.all.select { |node| node.include?('_') }

    groups = node_nested.group_by { |n| n.parent.object_id }

    groups.each_value { |nodes|
      if nodes.size >= 2
        parent = nodes[0].parent

        nodes.each { |n|
          last_par = n.split('_').reverse.inject(parent) { |par, child|
            par << child
            child
          }

          n.children.each { |c|
            c.parent >> c
            last_par << c
          }
          
          parent >> n
        }
      end
    }
    
    # group same nodes
    # criteria : no same subnodes under them
    @tree.all.group_by.select { |n| !n.leaf? and !n.children.any? { |c| XText === c } and tree.all.count(n) > 1 }.uniq.each { |multi_node|
      @tree.all.select { |n| n == multi_node }.group_by(&:depth).each_value { |group|
        group.slice_before([]) { |g, children|
          r = !(g.children & children).empty?
          children.clear if r
          children.concat g.children
          r
        }.each do |merging|
          children = merging.inject([]) { |cc, n| cc + n.children }
          
          if merging.size > 1
            first = merging.shift
            children.each { |child|
              unless first.children.any? { |c| c.equal? child }
                child.parent >> child
                first << child
              end
            }
            merging.each { |n| n.parent >> n }
            @tree.all.select { |n| n.leaf? and XNode === n }.each { |n| n.parent >> n }
          end
        end
      }
    }
  end

  def structure
    @structure.size.times { |i|
      @tree.all.select { |n| n.depth == i and n != @structure[i] }.each { |n|
        n.replace(@structure[i])
      }
    }
  end

  def transform
    aliases
    nesting
    structure
    @tree
  end
end

=begin
f = File.join(DIR, "nesting.xml")
#f = File.join(DIR, "source1.xml")
xml = XMLTransformer.new(f)

puts xml.tree.show_simple
puts

xml.transform
puts xml.tree.show_simple

puts
puts xml.result_tree.show_simple

puts
puts xml.tree.to_nokogiri_doc

if __FILE__ == $0
  require "test/unit"

  class TestXMLTransformer < Test::Unit::TestCase
    %w[source1 source2 source3 nesting].each { |f|
      define_method("test_#{f}") {
        xml = XMLTransformer.new("#{DIR}/#{f}.xml")
        assert_equal IO.read("#{DIR}/#{TARGET}.xml"), xml.transform.to_nokogiri_doc.to_s.strip
      }
    }
  end
end
=end