require 'rubygems'
require 'nokogiri'
require 'transformer'
require 'people_transformer'
require 'address_book_transformer'
require 'employees_transformer'
require 'people'
require 'person'
require 'test/unit'

# You can call this API one of two ways.  First, if you call
# Transformer.transform(file_name), it will try all transformers
# until it finds one that works.  If you know ahead of time which
# transformer you want to use for a file, you can call
# PersonTransformer.new(file_name).transform, which will only try
# that specific transformer

class TransformerTest < Test::Unit::TestCase
  def test_transform_people_with_transformer
    assert_equal File.read("result.xml").chomp,
      Transformer.transform("source1.xml").chomp
  end
  def test_transform_address_book_with_transformer
    assert_equal File.read("result.xml").chomp,
      Transformer.transform("source2.xml").chomp
  end
  def test_transform_employees_with_transformer
    assert_equal File.read("result.xml").chomp,
      Transformer.transform("source3.xml").chomp
  end
  def test_transform_people_with_people_transformer
    assert_equal File.read("result.xml").chomp,
      PeopleTransformer.new("source1.xml").transform.chomp
  end
  def test_transform_address_book_with_address_book_transformer
    assert_equal File.read("result.xml").chomp,
      AddressBookTransformer.new("source2.xml").transform.chomp
  end
  def test_transform_employees_with_employees_transformer
    assert_equal File.read("result.xml").chomp,
      EmployeesTransformer.new("source3.xml").transform.chomp
  end
  def test_transform_people_with_address_book_transformer
    assert_nil AddressBookTransformer.new("source1.xml").transform
  end  
end