require 'test/unit'
require 'xml_name_finder_1.rb'

$r = IO.read('../xmlfiles/result.xml').gsub(/\s/, '')
$s1 = '../xmlfiles/source1.xml'
$s2 = '../xmlfiles/source2.xml'
$s3 = '../xmlfiles/source3.xml'
$out = 'xml_output'

class TransformerTest < Test::Unit::TestCase
  def stub_method s
    transform(s)
    #assert_equal $r, IO.read($out).gsub(/\s/, '').gsub('encoding="UTF-8"', '')
    assert_equal $r, IO.read($out).gsub(/\s/, '')
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