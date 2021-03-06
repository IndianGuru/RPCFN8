require 'test/unit'
require 'rpcfn8_1.rb'

$r = IO.read('../xmlfiles/result.xml').gsub(/\s/, '')
$s1 = '../xmlfiles/source1.xml'
$s2 = '../xmlfiles/source2.xml'
$s3 = '../xmlfiles/source3.xml'
$out = 'xml_output'

class TransformerTest < Test::Unit::TestCase
  def stub_method s
    open $out, 'w' do |out|
      transform(s, out)
    end
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