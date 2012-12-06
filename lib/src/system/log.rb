# Creates logfiles
# UNTESTED / UNFINISHED (missing: .warn, .err, .report)

class Log
  
  def initialize(path,rendering=:plane)
    @log = File.new("#{path}/log_#{Time.now}.log")
    @warning = nil#File.new("#{path}/warnings_#{Time.now}.log")
    @error = nil
    @crash = nil#File.new("#{path}/")
    @time = Time.now
    @path = path
    @mode = rendering
    @faccess = [false,false,false,false]
  end
  
  def puts(string)
    @log << "#{string}\n"
  end
  
  def print(string)
    @log << string
  end
  
  def crash(err_mssg,loaded_modules,strace)
    @crash = File.new("#{@path}/crashlog_#{Time.now}.log")
    @crash << "--- CRASH REPORT ---"
    @crash << "Time: #{Time.now}"
    @crash << "Start: #{@time}"
    @crash << "Running: #{Time.now-@time}"
    @crash << "Version: #{VCore.version}"
    @crash << "Version: #{VCore.revision}"
    
    @crash << "\n-------- LOG -------"
    @crash << "Exeption: #{err_mssg}"
    @crash << "\nModules:"
    
    i = 0
    for element in loaded_modules
      @crash << "#{i}: #{element[0]} -> #{element[1]}"
      i += 1
    end
    
    @crash << "\n--- STACKTRACE ---"
    # resolve stacktrace here
  end
  
  def close
    @log.close if @log
    @warning.close if @warning
    @error.close if @error
    @crash.close if @crash
  end
end
