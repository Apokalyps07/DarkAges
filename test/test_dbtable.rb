# Testing: dbtable
# Path: ../src/system/dbtable.rb
# Tested: yes
# Status: Stable
# Version: 0.1.4
# Author: Apokalyps07

# TESTCODE START #

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
# TESTCODE END #


# EXCEPTION CODE START #
class DBError < Exception; end
# EXCEPTION CODE END #

class TestDB < Test::Unit::TestCase
  def test_complete_unit
    puts ">Begin Testing."
    
    puts "\n\n>Creating new Table :car with [:brand,:color,:gears,:max_speed]:"
    test_table = DBTable.new(:car, [:brand,:color,:gears,:max_speed])
    
    puts "Testing: [:brand,:color,:gears,:max_speed] = test_table.columns"
    assert_equal([:brand,:color,:gears,:max_speed], test_table.columns)
    puts "Testing: 0 = test_table.size"
    assert_equal(0,test_table.size)
    puts "Testing: 0 = test_table.lenth"
    assert_equal(0,test_table.length)
    
    puts "\n>Creating row in :car with [Audi,red,6,180]"
    
    puts "Testing: [0,4] = test_table.add"
    assert_equal([0,4], test_table.add(["Audi","red",6,180]))
    puts "Testing: [Audi,red,6,180] = test_table.get(0)"
    assert_equal(["Audi","red",6,180], test_table.get(0))
    puts "Testing: 180 = test_table.getbyname(0,:max_speed)"
    assert_equal(180, test_table.getbyname(0,:max_speed))
    
    puts"\n>Edit entrie 0 with [Audi,blue,7,220]"
    
    puts "Testing: [0,3,[Audi,red,6,180]] = test_table.edit"
    assert_equal([0,3,["Audi","red",6,180]], test_table.edit(["Audi","blue",7,220], 0))
    puts "Testing: [Audi,blue,7,220] = test_table.get(0)"
    assert_equal(["Audi","blue",7,220], test_table.get(0))
    puts "Testing: blue = test_table.getbyname(0,:color)"
    assert_equal("blue", test_table.getbyname(0,:color))
    puts "Testing: 1 = test_table.length"
    assert_equal(1, test_table.length)
    puts "Testing: 4 = test_table.size"
    assert_equal(4, test_table.size)
    puts "Testing: nil = test_table.get(122)"
    assert_equal(nil, test_table.get(122))
    puts "Testing: nil = test_table.get(-3)"
    assert_equal(nil, test_table.get(-3))
    puts "Testing: nil = test_table.get(test_table.length)"
    assert_equal(nil, test_table.get(test_table.length))
    puts "Testing: nil = test_table.getbyname(113)"
    assert_equal(nil, test_table.getbyname(113,:color))
    puts "Testing: nil = test_table.getbyname(-7)"
    assert_equal(nil, test_table.getbyname(-7,:color))
    puts "Testing: nil = test_table.get(test_table.length,:color)"
    assert_equal(nil, test_table.getbyname(test_table.length,:color))
    
    puts"\nEdit entrie 3 with [Opel,black,6,140]"
    
    puts "Testing: [3,4,[nil,nil,nil,nil]] = test_table.edit <= DBError"
    assert_raise(DBError){ test_table.edit(["Opel","black",6,140], 3) }
    puts "Testing: test_table2 = DBTable.new(:bike,[color,gears]) <= TypeError"
    assert_raise(TypeError){ test_table2 = DBTable.new(:bike,["color","gears"])}
    puts "Testing: test_table3 = DBTable.new(ships,[:color,:ps]) <= TypeError"
    assert_raise(TypeError){ test_table3 = DBTable.new("ships",[:color,:ps])}
    puts "Testing: test_table4 = DBTable.new(:aircrafts,[:speed,:speed,:length]) <= DBError"
    assert_raise(DBError){ test_table4 = DBTable.new(:aircrafts, [:speed,:speed,:legth])}
    puts "Testing: test_table5 = DBTable.new(:aircrafts,[:speed,:length,:weight,:weight]) <= DBError"
    assert_raise(DBError){ test_table5 = DBTable.new(:aircrafts, [:speed,:legth,:weight,:weight])}
    puts "Testing: test_table.getbyname(0,:banana) <= DBError"
    assert_raise(DBError){ test_table.getbyname(0,:banana)}
  end
  
  def test_get_methods
    puts ">Begin Testing."
    
    puts "\n\n>Creating new Table :car with [:brand,:color,:gears,:max_speed]:"
    test_table2 = DBTable.new(:car, [:brand,:color,:gears,:max_speed])
    puts ">Adding contents [Audi,red,6,180]"
    test_table2.add(["Audi","red",6,180])
    
    puts "Tesing: [[Audi,red,6,180]] = test_table2.getbyvalue({:brand => Audi})"
    assert_equal([["Audi","red",6,180]],test_table2.getbyvalue({:brand => "Audi"}))
    puts "Testing: [[Audi,red,6,180]] = test_table2.get_by_exact_value({:brand => Audi :color => red :gears => 6 :max_speed => 180}))"
    assert_equal([["Audi","red",6,180]], test_table2.get_by_exact_value({:brand => "Audi", :color => "red", :gears => 6, :max_speed => 180}))
    puts "Testing: [[Audi,red,6,180]] = test_table2.getbyclass({:brand => \"\"})"
    assert_equal([["Audi","red",6,180]],test_table2.getbyclass({:brand => ""}))
    puts "Testing: [[Audi,red,6,180] = test_table2.get_by_exact_class({:brand => \"\" :color => \"\" :gears => 0 :max_speed => 0}))"
    assert_equal([["Audi","red",6,180]], test_table2.get_by_exact_class({:brand => "", :color => "", :gears => 0, :max_speed => 0}))
  end
  
  def test_err_get_methods
    puts ">Begin Testing."
    
    puts "\n\n>Creating new Table :car with [:brand,:color,:gears,:max_speed]:"
    test_table3 = DBTable.new(:car, [:brand,:color,:gears,:max_speed])
    puts ">Adding contents [Audi,red,6,180]"
    test_table3.add(["Audi","red",6,180])
    
    puts "Testing: test_table3.getbyvalue({:tiers => 4})"
    assert_raise(DBError){test_table3.getbyvalue({:tiers => 4})}
    puts "Testing: [[]] = test_table3.get_by_exact_value({:brand => Opel})"
    assert_equal([[]], test_table3.get_by_exact_value({:brand => "Opel"}))
    puts "Testing: [[]] = test_table3.get_by_exact_class({:brand => 0})"
    assert_equal([[]], test_table3.get_by_exact_class({:brand => 0}))
    
    puts "\n\n>Tests completed."
  end
end