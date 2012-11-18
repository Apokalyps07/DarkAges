# 
# 

class Questlog
  attr_reader :gui
  TABLE_NAME = :quests
  
  def initialize(gui_handler)
    $db.create_table(:quests, [:name,:heading,:descriptions,:area,:part,:status,:type,:collected])
    @quest_id = Hash.new
    @gui = gui_handler
  end
  
  # Add new quest
  # Collection template:
  # {:token => [str displayed_name_singular, str displayed_name_plural, int player_has_collected, int player_should_collect]}
  def add(name,heading,descriptions,area,type,collection)
    data = $db.add(:quests, [name,heading,descriptions,area,0,:inactive,type,collection])
    @quest_id[name] = data[0]
  end
  
  # Set a quest to active
  def activate(name)
    $db.edit(:quests, @quest_id[name], {:status => :active})
    @gui.update
  end
  
  # Set a quest to inactive
  def deactivate(name)
    $db.edit(:quests, @quest_id[name], {:status => :inactive})
    @gui.update
  end
  
  # Set a quest to failed (status)
  def failed(name)
    $db.edit(:quests, @quest_id[name], {:status => :failed})
    @gui.update
  end
  
  # Set a quest du succseded
  def success(name)
    $db.edit(:quests, @quest_id[name], {:status => :success})
    @gui.update
  end
  
  # Proceed in the quests storyline (increments :part by one)
  def proceed(name)
    prev_stat = $db.getbyname(:quests, @quest_id[name], :part)
    $db.edit(:quests, @quest_id[name], {:part => prev_stat+1})
    @gui.update
  end
  
  # Get all collected items (empty Hash if not given)
  def get_collected(name)
    $db.getbyname(:quests, @quest_id[name], :collected)
    @gui.update
  end
  
  # Update collected items
  def update_collected(name,token,value)
    collected = $db.get(:quests, @quest_id[name])
    cvalue = collected[token] + value
    $db.edit(:quests, @quest_id[name], {token => cvalue})
    @gui.update
  end
  
  # Add player collected item
  def update_player_collected(name,value=1)
    collected = $db.get(:quests, @quest_id[name])
    cvalue = collected[:player] + value
    $db.edit(:quests, @quest_id[name], {:player => cvalue})
    @gui.update
  end
  
  # Delete a quest and return a copy of it
  def delete(name)
    copy = $db.get(:quests, @quest_id[name])
    $db.delete(:quests, @quest_id[name])
    @gui.update
    copy
  end
  
  # Delete a quest and return nothing
  def delete!(name)
    $db.delete(:quests, @quest_id[name])
    @gui.update
    nil
  end
end
