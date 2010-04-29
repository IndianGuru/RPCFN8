require 'test/unit'
require 'richardcolley_1.rb'

$r = IO.read('../xmlfiles/result.xml').gsub(/\s/, '')
$s1 = '../xmlfiles/source1.xml'
$s2 = '../xmlfiles/source2.xml'
$s3 = '../xmlfiles/source3.xml'


class TransformerTest < Test::Unit::TestCase
  def stub_method s
    transformer = Transformer.new
    indoc = ''
    open(s){|f| indoc = Nokogiri::XML(f)}
    #assert_equal $r, transformer.transform(indoc).to_s.gsub(/\s/, '').gsub('<age/>', '')
    assert_equal $r, transformer.transform(indoc).to_s.gsub(/\s/, '')
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