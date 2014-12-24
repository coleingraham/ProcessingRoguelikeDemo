/*
 * An actor within the battle system
 */
class CombatActor
{
  String name;
  Action[] actions;
  CharacterSheet stats;
  Entity parent;
  boolean canAct;
 
  CombatActor(JSONObject json, Entity p)
  {
    name = json.getString("name");
    stats = loadJSONStats(json.getJSONObject("stats"));
    actions = loadJSONActions(json.getJSONArray("actions"));
    parent = p;
    canAct = true;
  }
  
  void setMaxHealth(int v)
  {
    stats.hp_max = v;
    stats.hp_max_base = v;
    if(stats.hp_current > stats.hp_max) { stats.hp_current = stats.hp_max;}
  }
  
  void setAttack(int v)
  {
    stats.physical_attack = v;
    stats.physical_attack_base = v;
  }
  
  void setDefense(int v)
  {
    stats.physical_defense = v;
    stats.physical_defense_base = v;
  }
  
  void setMagAttack(int v)
  {
    stats.magic_attack = v;
    stats.magic_attack_base = v;
  }
  
  void setMagDefense(int v)
  {
    stats.magic_defense = v;
    stats.magic_defense_base = v;
  }
  
  void updateActions()
  {
    for(int i=0; i<actions.length; i++)
    {
      actions[i].update();
    }
  }
  
  void forceCooldown()
  {
    for(int i=0; i<actions.length; i++)
    {
      actions[i].cooldown();
    }
  }
  
  /**
   * Load a CharacterSheet from the supplied JSONObject
   */
  CharacterSheet loadJSONStats(JSONObject json)
  {
    CharacterSheet stats = new CharacterSheet();
    
    stats.hp_max_base = json.getInt("hp_max_base");
    stats.hp_max = stats.hp_max_base;
    stats.hp_current = stats.hp_max;
    
    stats.physical_attack_base = json.getInt("physical_attack_base");
    stats.physical_attack = stats.physical_attack_base;
    
    stats.magic_attack_base = json.getInt("magic_attack_base");
    stats.magic_attack = stats.magic_attack_base;
    
    stats.physical_defense_base = json.getInt("physical_defense_base");
    stats.physical_defense = stats.physical_defense_base;
    
    stats.magic_defense_base = json.getInt("magic_defense_base");
    stats.magic_defense = stats.magic_defense_base;
    
    if(!json.isNull("status_effects"))
    {
      JSONArray effects = json.getJSONArray("status_effects");
      for(int i=0; i<effects.size(); i++)
      {
       JSONObject e = effects.getJSONObject(i);
       stats.status_effects.put(e.getString("name"),e.getBoolean("state"));
      }
    }

    return stats;
  }
  
  /*
   * Load Actions from the supplied JSONArray
   */
  Action[] loadJSONActions(JSONArray json)
  {
    Action[] actions = new Action[json.size()];
    
    String action;
    for(int i=0; i<actions.length; i++)
    {
      action = json.getString(i) + ".action";
      actions[i] = new Action(loadJSONObject(action));
    }
    
    return actions;
  }
}
