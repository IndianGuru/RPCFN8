class People
  def initialize(people=[])
    @people = people
  end
  def <<(person)
    @people << person
  end
  def empty?
    @people.empty?
  end
  def to_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.people do
        @people.each do |p|
          xml.person do
            xml.name do
              xml.first p.first_name
              xml.last p.last_name
            end
          end
        end
      end
    end.to_xml
  end
end