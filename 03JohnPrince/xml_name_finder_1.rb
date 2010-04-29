require 'builder'

=begin
if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <input>.xml ..."
  puts "output: <input>.result.xml ..."
  exit
end

ARGV.each do |file|
  File.open(file.sub(/\.xml/,'.result.xml'), 'w') do |out|
=end

  
def transform file
  open $out, 'w' do |out|
    xml = Builder::XmlMarkup.new(:target => out, :indent => 2)
    xml.instruct!
    xml.people do |people|
      first_name = nil
      IO.foreach(file) do |line|
        if md = line.match(/<(.*)>(.*)<\/\1>/)
          case md[1]
          when /first/
            first_name = md[2]
          when /last|sur/
            people.person do |person|
              person.name do |name|
                name.first first_name
                name.last md[2]
              end
            end
          end
        end
      end
    end
  end
end

