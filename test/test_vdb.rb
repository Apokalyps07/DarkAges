# DEPEDENCIES START #

class DBTable
  attr_reader :name
  attr_reader :columns
  
  FLAT_OUTPUT = true

  
  # Creates a new Database Table (Helper class of VDB)
  #
  # DBTable.initialize(:car, [:gears,:max_speed,:color,:brand])
  # =>
  # 
  # #--------------------------------------------------------#
  # #                         car                            #
  # #--------------------------------------------------------#
  # # gears     |                  nil                       #
  # # max_speed |                  nil                       #
  # # color     |                  nil                       #  
  # # brand     |                  nil                       #
  # #--------------------------------------------------------#
  #
  def initialize(identifier,columns)
    
    # Check validation
    raise TypeError unless identifier.is_a? Symbol
    for element in columns do
      raise TypeError unless element.is_a? Symbol
    end
    
    # Check if column entries exists more than once
    tcopy = columns.sort
    i = 0
    while i < tcopy.size do
      break if i == tcopy.size
      raise DBError if tcopy[i] == tcopy[i+1]
      i += 1
    end
    
    @name = identifier.to_sym
    @table = Array.new
    @columns = columns
    
    # Make flat copy
    @row = Hash.new
    for element in columns do
      @row[element] = nil
    end
    nil
  end
  
  # Add a new row
  # column_values hat to be the same size as @columns if an array is given
  def add(column_values)
    # Process different if array
    if column_values.is_a? Array
      flatcopy = @row
      keys = @row.keys
      i = 0
      while i < @columns.size do
        flatcopy[keys[i]] = column_values[i]
        i += 1
      end
      @table << flatcopy
      return [@table.size-1,column_values.size]
    end
    
    flatcopy = @row
    added = 0
    for key,value in column_values do
      next unless @columns.include? key
      flatcopy[key] = value
      added += 1
    end
    
    @table << flatcopy
    [@table.size-1,added]
  end
  
  # Edit row (previous row will be deleted)
  def edit(column_values,id,flat_output=FLAT_OUTPUT)
    raise DBError unless @table[id]
    # Process different if array
    if column_values.is_a? Array
      flatcopy = @row
      savecopy = @table[id].clone
      added = 0
      keys = @row.keys
      i = 0
      while i < @columns.size do
        flatcopy[keys[i]] = column_values[i]
        i += 1
        added += 1 if column_values[i] != savecopy[keys[i]]
      end
      @table[id] = flatcopy
      return [@table.size-1,added,savecopy] unless flat_output
      
      flatsave = Array.new
        for key,value in savecopy
      flatsave << value
        end
      return [id,added,flatsave]
    end
    
    flatcopy = @row
    savecopy = @table[id].clone
    added = 0
    for key,value in column_values do
      next unless @columns.include? key
      flatcopy[key] = value
      added += 1 if value != savecopy[key]
    end
    
    @table[id] = flatcopy
    return [id,added,savecopy] unless flat_output
    
    flatsave = Array.new
    for key,value in savecopy
      flatsave << value
    end
    [id,added,flatsave]
  end
  
  # Get row by id
  def get(id,flat_output=FLAT_OUTPUT)
    return nil if id > @table.size-1 or id < 0
    return @table[id] unless flat_output
    flatout = Array.new
    for key,value in @table[id]
      flatout << value
    end
    flatout
  end
  
  # get specific entrie by name
  def getbyname(id,column)
    return nil if id > @table.size-1 or id < 0
    raise DBError unless @columns.include? column
    return @table[id][column]
  end
  
  # get all rows witch columns matches certain values
  # Match table:
  # {column => value}
  # Min. 1 column has to be true
  def getbyvalue(match_table,flat_output=FLAT_OUTPUT)
    return [[]] if match_table.empty?
    output = []
    
    # Check if keys exists
    for column,value in match_table do
      raise DBError unless @columns.include? column
    end
    
    for row in @table
      for column,value in match_table do
        next if row[column] != value
        output << row
        break
      end
    end
    
    return [[]] if output.empty?
    return output unless flat_output
    
    flatcopy = []
    buffer = []
    for hash in output
      for column, value in hash
        buffer << value
      end
      flatcopy << buffer
      buffer = []
    end
    
    flatcopy
  end
  
  # get all rows witch column matches a certain class
  # Match table:
  # {column => class_ref}
  # All columns have to be true
  def get_by_exact_value(match_table,flat_output=FLAT_OUTPUT)
    return [[]] if match_table.empty?
    output = []
    match = 0
    max = match_table.size
    
    # Check if keys exists
    for column,value in match_table do
      raise DBError unless @columns.include? column
    end
    
    for row in @table
      for column,value in match_table do
        break if row[column] != value
        match += 1
      end
      output << row if match == max
      match = 0
    end
    
    return [[]] if output.empty?
    return output unless flat_output
    
    flatcopy = []
    buffer = []
    for hash in output
      for column, value in hash
        buffer << value
      end
      flatcopy << buffer
      buffer = []
    end
    
    flatcopy
  end
  
  # get all rows witch column matches a certain class
  # Match table:
  # {column => class_ref}
  # Min. 1 column has to be true
  def getbyclass(match_table,flat_output=FLAT_OUTPUT)
    return [[]] if match_table.empty?
    output = []
    
    # Check if keys exists
    for column,class_ref in match_table do
      raise DBError unless @columns.include? column
    end
    
    for row in @table
      for column,class_ref in match_table do
        next if row[column].class != class_ref.class
        output << row
        break
      end
    end
    
    return [[]] if output.empty?
    return output unless flat_output
    
    flatcopy = []
    buffer = []
    for hash in output
      for column, value in hash
        buffer << value
      end
      flatcopy << buffer
      buffer = []
    end
    
    flatcopy
  end
  
  # get all rows witch column matches a certain class
  # Match table:
  # {column => class_ref}
  # All columns have to be true
  def get_by_exact_class(match_table,flat_output=FLAT_OUTPUT)
    return [[]] if match_table.empty?
    
    output = []
    match = 0
    max = match_table.size
    
    # Check if keys exists
    for column,class_ref in match_table do
      raise DBError unless @columns.include? column
    end
    
    for row in @table
      for column,class_ref in match_table do
        break if row[column].class != class_ref.class
        match += 1
      end
      output << row if match == max
      match = 0
    end
    
    return [[]] if output.empty?
    return output unless flat_output
    
    flatcopy = []
    buffer = []
    for hash in output
      for column, value in hash
        buffer << value
      end
      flatcopy << buffer
      buffer = []
    end
    
    flatcopy
  end
  
  # Number of rows in the table
  def length
    return 0 if @table.size == 1 and @table[0].is_a?(Hash) == false
    @table.size
  end
  
  # Number of total entries in the table
  def size
    return 0 if @table.size == 1 and @table[0].is_a?(Hash) == false
    @table.size * @columns.size
  end
  
end
# DEPEDENCIES END #

# TESTCODE START #

class VDB
  attr_reader :current_tables
  attr_reader :max_tables
  
  FLAT_OUTPUT = true
  
  # Create new virtual database
  def initialize(max_tables=nil)
    @max_tables = max_tables
    @current_tables = 0
    # {:name => DBTable}
    @tables = Hash.new
    true
  end
  
  # Create a new Table
  def create_table(table_name,columns)
    if @max_tables == nil or @current_tables < @max_tables
      @tables[table_name.to_sym] = DBTable.new(table_name.to_sym,columns)
      @current_tables += 1
      return true
    end
    false
  end
  
  # Edit an existant row within a table
  def edit(table_name,id,column_values)
    return nil unless @tables.has_key? table_name
    @tables[table_name].edit(column_values,id)
  end
  
  # Add a row to a table
  # Row ID will be outputed
  def add(table_name,column_values)
    return nil unless @tables.has_key? table_name
    @tables[table_name].add(column_values)
  end
  
  # Delete a row in a table.
  # Row ID has to be existent
  # Deleted entry will be outputed.
  def delete(table_name,id)
    return nil unless @tables.has_key? table_name
    @tables[table_name].edit(Array.new(@tables.columns.size, nil),id)
  end
  
  # Delete a table
  def delete_table(table_name)
    return nil unless @tables.has_key? table_name
    @current_tables -= 1
    @tables.delete table_name
  end
  
  # Get a rows value within a table.
  # The row has to be existent.
  def get(table_name,id,flat=FLAT_OUTPUT)
    return nil unless @tables.has_key? table_name
    @tables[table_name].get(id)
  end
  
  # Get the value of a column in a certain row within a table
  def getbyname(table_name,id,column)
    return nil unless @tables.has_key? table_name
    @tables[table_name].getbyname(id,column)
  end
  
  # get all rows witch column matches a certain value
  # Match table:
  # {column => class_ref}
  # all_match checks if all columns matches the particullar value
  def getbyvalue(table_name,match_table,all_match=true)
    return nil unless @tables.has_key? table_name
    
    return get_by_value(table_name,match_table) if all_match
    get_by_exact_value(table_name,match_table)
  end
  
  # get all rows witch column matches a certain value (helper method)
  # Match table:
  # {column => class_ref}
  # Min. 1 column has to be true
  def get_by_value(table_name,match_table)
    return nil unless @tables.has_key? table_name
    @tables[table_name].getbyvalue(match_table)
  end
  
  # get all rows witch column matches a certain value (helper method)
  # Match table:
  # {column => class_ref}
  # All columns have to be true
  def get_by_exact_value(table_name,match_table)
    return nil unless @tables.has_key? table_name
    @tables[table_name].get_by_exact_value(match_table)
  end
  
  # get all rows witch column matches a certain class
  # Match table:
  # {column => class_ref}
  # all_match checks if all columns matches the particullar class reference
  def getbyclass(table_name,match_table,all_match=true)
    return nil unless @tables.has_key? table_name
   
    return get_by_class(table_name,match_table) if all_match
    get_by_exact_class(table_name,match_table)
  end
  
  # get all rows witch column matches a certain class (helper method)
  # Match table:
  # {column => class_ref}
  # Min. 1 column has to be true
  def get_by_class(table_name,match_table)
    return nil unless @tables.has_key? table_name
    @tables[table_name].getbyclass(match_table)
  end
  
  # get all rows witch column matches a certain class (helper method)
  # Match table:
  # {column => class_ref}
  # All columns have to be true
  def get_by_exact_class(table_name,match_table)
    return nil unless @tables.has_key? table_name
    @tables[table_name].get_by_exact_class(match_table)
  end
  
  # Outputs the columns used in the table
  def getcolumns(table_name)
    return nil unless @tables.has_key? table_name
    @tables[table_name].columns
  end
  
  # Output total number of entries in the table
  def size(table_name)
    return nil unless @tables.has_key? table_name
    @tables[table_name].size
  end
  
  # Outputs total number of rows in a table
  def length(table_name)
    return nil unless @tables.has_key? table_name
    @tables[table_name].length
  end
  
  # Outputs total numbers of entries in the database
  def dbsize
    return 0 if @max_tables == 0
    total = 0
    for key,table in @tables
      total = total + table.size
    end
    total
  end
  
  # Outputs total numers of rows in the database
  def dblength
    return 0 if @max_tables == 0
    total = 0
    for key,table in @tables
      total = total + table.length
    end
    total
  end
end
# TESTCODE END #

# EXCEPTIONS START #
class DBError < Exception; end
# EXCEPTIONS END #

# TESTING START #
class TestDB < Test::Unit::TestCase
  BENCHMARK_LOOPS = 9999
  def test_basics
    puts "\n\n>Creating VDB vdb"
    vdb = VDB.new
    
    puts "\n>Creating Table :cars with [:brand,:color,:speed,:prize]"
    
    puts "Testing: true = vdb.create_table(:cars,[:brand,:color,:speed,:prize])"
    assert_equal(true, vdb.create_table(:cars,[:brand,:color,:speed,:prize]))
    puts "Testing: nil = vdb.delete_table(:ships)"
    assert_equal(nil, vdb.delete_table(:ships))
    puts "Testing: 0 = vdb.dbsize"
    assert_equal(0, vdb.dbsize)
    puts "Testing: 0 = vdb.dblength"
    assert_equal(0, vdb.dblength)
  end
  
  def test_performance
    puts "\n>Creating performance Test."
    t = Time.now
    i = 0
    vdb2 = VDB.new
    charbuffer = ["A","b","g","f","z","e","l","p","F","B","K","V","s","j","m","Q","x","G","r"]
    puts ">Begin Benchmark @ #{Time.now}"
    while i <= BENCHMARK_LOOPS
      randwrd = ""
      p = 0
      while p <= 6
        randwrd << charbuffer[rand(charbuffer.size-1)]
        p += 1
      end
      vdb2.create_table(randwrd.to_sym,[randwrd.to_sym])
      i += 1
    end
    
    #tb = Time.now - t
    #while i <= BENCHMARK_LOOPS 
    #  randwrd = ""
    #  p = 0
    #  while p <= 6
    #    randwrd << charbuffer[rand(charbuffer.size-1)]
    #    p += 1
    #  end
    #  i += 1
    #end
    
    puts ">Stop Benchmark @+ #{Time.now-t}"
    
    puts "\n>Finalizing."
    puts "Testing: 10000 = vdb2.current_tables"
    assert_equal(10000, vdb2.current_tables)
  end
end
# TESTING END #