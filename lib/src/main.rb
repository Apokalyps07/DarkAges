# Load all components

puts ">Loading components..."

puts "1/3"
require "./game/questlog"

puts "2/3"
require "./system/vdb"

puts "3/3"
require "./system/system_excepions"

puts ">Initializing..."

puts "1/2"
$db = VDB.new

puts "2/2"
$questlog = Questlog.new
