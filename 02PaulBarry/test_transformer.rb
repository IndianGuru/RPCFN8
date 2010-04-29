require 'rubygems'
require 'nokogiri'
require 'transformer'
require 'people_transformer'
require 'address_book_transformer'
require 'employees_transformer'
require 'people'
require 'person'
require 'test/unit'

$r = IO.read('../xmlfiles/result.xml').gsub(/\s/, '')
$s1 = '../xmlfiles/source1.xml'
$s2 = '../xmlfiles/source2.xml'
$s3 = '../xmlfiles/source3.xml'


class TransformerTest < Test::Unit::TestCase
  def stub_method s
    assert_equal $r, Transformer.transform(s).to_s.gsub(/\s/, '')
  end
  
  def test_source1
    stub_method $s1
  end
  
  def test_source2
    stub_method $s2
  end
  
  def test_source3
    stub_method $s3
  end 

end