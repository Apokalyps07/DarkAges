# Helper class for the VDB
# Creates a new Table

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