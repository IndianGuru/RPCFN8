require 'rubygems'
require 'nokogiri'
#
class Challenge
  FIRST_NAME = %q{first, first_name}
  LAST_NAME = %q{last, last_name, surname}
  def initialize(filename)  
    @input_file = filename
  end
  
  def parse
     f = File.open(@input_file)
     input_doc = Nokogiri::XML(f)
     f.close
      people_doc = nil
      if File.exists?("result.xml")
        f = File.open("result.xml")
        people_doc = Nokogiri::XML(f)
        f.close
      else
        people_doc  = Nokogiri::XML("<people/>")  
      end
      people = people_doc.at_css('people')
      input_doc.css(FIRST_NAME.to_s).each do |node|
       first= Nokogiri::XML::Node.new('first', people_doc)
       first.content = node.content
       lastname = node.parent.at_css(LAST_NAME.to_s)
       last = Nokogiri::XML::Node.new('last', people_doc)
       last.content = lastname.content
       person = Nokogiri::XML::Node.new('person', people_doc)
       person << first
       person << last
       people << person
       old_people = people_doc.css('people');
       old_people.remove
       people_doc << people
       f = File.open('result.xml',"w"){|f| f.write(people_doc.to_xml)}
      end
  end
end
x = Challenge.new('source1.xml')
x.parse
