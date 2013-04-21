# Parses *.dbe, *.vdbe
# Table has to be existent (vdb_hook)
# Apokalyps07
require "./bin/lib/rexml/document"
include REXML

module DBEParser
  # pending, will be added when load/save concept is finished
  @@vdb = SOME_STD_VDB_LOAD_SAVE_STUFF

  # DTD currently not supported :(
  def self.parse(path,auto_input=true,dtd_path=nil)
    doc = Document.new(path)
    @@data = [[]]
    table_root = doc.elements["root"].to_sym
    
    @@doc = case table_root
    when "weapon" then parse_weapon(doc)
    when "shield" then parse_shield(doc)
    else parse_std(doc)
    end
    
    return [table_root,@@data] unless auto_input
    # Expect entitie order like parsing order
    for data_set in @@data do
      @@vdb.add(table_root,data_set)
    end
  end

  #Ducktyping supported
  def self.set_vdb_hook(vdb_hook)
    @@vdb = vdb_hook
  end

  # Parse other item files
  def parse_std(doc)
    data = [[]]
    i = 0
    doc.elements.each("rweapon/weapon") {|element|
      # Single entries
      data[i][0] << element.attributes["id"]
      data[i][1] << element.attributes["name"]
      data[i][2] << element.attributes["desc_id"]
      data[i][3] << element.attributes["worth"]
      data[i][4] << element.attributes["weight"]
      data[i][5] << element.attributes["sockets"]
      data[i][6] << element.attributes["rhand"]
      data[i][7] << element.attributes["rarity"]
      data[i][8] << element.attributes["material"]
      data[i][9] << element.attributes["set_index_id"]

      # Multiple entries
      data[i][10] << element.attributes["stat_index"].scan(",")
      data[i][11] << element.attributes["stat_change_index"].scan(",")
      data[i][12] << element.attributes["stat_change_value"].scan(",")
      data[i][13] << element.attributes["char_usage_index"]
      data[i][13].scan(",") if data[i][14].include? ","
      data[i][14] << element.attributes["script_event_id"].scan(",")
      i += 1
    }
    return data
  end

  # Parse weapon item files
  def parse_weapon(doc)
    data = [[]]
    i = 0
    doc.elements.each("rweapon/weapon") {|element|
      # Single entries
      data[i][0] << element.attributes["id"]
      data[i][1] << element.attributes["name"]
      data[i][2] << element.attributes["desc_id"]
      data[i][3] << element.attributes["worth"]
      data[i][4] << element.attributes["weight"]
      data[i][5] << element.attributes["length"]
      data[i][6] << element.attributes["sockets"]
      data[i][7] << element.attributes["rhand"]
      data[i][8] << element.attributes["rarity"]
      data[i][9] << element.attributes["material"]
      data[i][10] << element.attributes["set_index_id"]

      # Multiple entries
      data[i][11] << element.attributes["stat_index"].scan(",")
      data[i][12] << element.attributes["stat_change_index"].scan(",")
      data[i][13] << element.attributes["stat_change_value"].scan(",")
      data[i][14] << element.attributes["char_usage_index"]
      data[i][14].scan(",") if data[i][14].include? ","
      data[i][15] << element.attributes["script_event_id"].scan(",")
      i += 1
    }
    return data
  end

  # Parse shield item files
  def parse_shield(doc)
    data = [[]]
    i = 0
    doc.elements.each("rweapon/weapon") {|element|
      # Single entries
      data[i][0] << element.attributes["id"]
      data[i][1] << element.attributes["name"]
      data[i][2] << element.attributes["desc_id"]
      data[i][3] << element.attributes["worth"]
      data[i][4] << element.attributes["weight"]
      data[i][5] << element.attributes["width"]
      data[i][6] << element.attributes["length"]
      data[i][7] << element.attributes["sockets"]
      data[i][8] << element.attributes["rhand"]
      data[i][9] << element.attributes["rarity"]
      data[i][10] << element.attributes["material"]
      data[i][11] << element.attributes["set_index_id"]

      # Multiple entries
      data[i][12] << element.attributes["stat_index"].scan(",")
      data[i][13] << element.attributes["stat_change_index"].scan(",")
      data[i][14] << element.attributes["stat_change_value"].scan(",")
      data[i][15] << element.attributes["char_usage_index"]
      data[i][15].scan(",") if data[i][14].include? ","
      data[i][16] << element.attributes["script_event_id"].scan(",")
      i += 1
    }
    return data
  end

end
