# Small helper module for the Questlog class
# Parses questtext

module QuestlogTextParser
  REG_MATCH = /{(\w*)\|(\w*)}/
  
  # Parses an encrypted questlog text. (Helper module)
  # Template:
  # You have to collect {carrot|max} {carrots|name_p}.
  # You have collected {carrot|player} out of {carrot|max} {carrot|name_p}.
  # ---
  # Output with {:carrot => ["carrot","carrots",5,0]}
  # You have to collect 5 carrots.
  # You have collected 0 out of 5 carrots.
  def self.parse(text,collections)
    while text.clone =~ REG_MATCH do
      text.sub!(REG_MATCH,resolve_data(collections,$~[1].to_sym,$~[2]))
    end
    text
  end
  
  # Helper method
  # Resolves header and token via collections data into an usable string
  def self.resolve_data(collections,header,token)
    
    token.to_sym unless token.is_a? Symbol
    out = case
      when header == :var then $gvar[token].to_s
      when token == :name_su then collections[header][0].capitalize if collections[header][0].capitalize
      when token == :name_s then collections[header][0]
      when token == :name_pu then collections[header][1].capitalize if collections[header][0].capitalize
      when token == :name_p then collections[header][1]
      when token == :max then collections[header][2].to_s
      when token == :player then collections[header][3].to_s
    end
  out
  end
  
end