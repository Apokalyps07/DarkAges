# unfinished

module QuestlogLanguageParser
    @@db = $db
    @@db_name = :quests
  
    def self.parse(path)
      # Parse here (REXML)
    end
    
    def db=(db_ref)
      @@db = db_ref
    end
    
    def db_name=(name)
      @@db_name = name
    end
end
