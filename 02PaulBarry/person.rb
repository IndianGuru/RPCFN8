class Person
  attr_accessor :first_name
  attr_accessor :last_name
  def initialize(attributes={})
    attributes.each do |k,v|
      send("#{k}=", v)
    end
  end
end