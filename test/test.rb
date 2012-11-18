# Function testing

class TestDB < Test::Unit::TestCase
  def test_basic
    puts "\n\n>Start testing:"
    
    string = "sequence 1 <header|token> sequence 2"
    out = string.clone.split(/<(\w*)\|(\w*)>/)
    
    puts "String splitting:"
    puts "String lenght: #{out.size}"
    puts "String1: #{out[0]} String2: #{out[1]} String3: #{out[2]} String4: #{out[3]}"
    
    prev_length = string.size
    # while string =~ /<(\w*)\|(\w*)>/ do
    out2 = string.sub!(/<(\w*)\|(\w*)>/,"<<function yet to come>>") ## resolving function here
    # end ## In completed parser
    out2 = string if out2 == nil
    length = out2.size
    puts "\nString subsituting:"
    puts "String lenght: #{length} (-#{prev_length})"
    puts "String: #{out2}"
    puts "String cutted: #{$~[1]} and #{$~[2]}"
  end
end
