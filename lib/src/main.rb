# Load all components and do important stuff

require "./game/questlog"
require "./system/vdb"
require "./system/system_excepions"

$db = VDB.new
$questlog = Questlog.new
$log = Log.new("./user")

begin
rescue
  $log.close
end