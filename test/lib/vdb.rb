# Creates a virtual database
# Should be made global in order to access it from anywhere ($db)

require "dbtable.rb"

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
    if @tables.size < @max_tables
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