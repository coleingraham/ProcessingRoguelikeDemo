/*
 * Absract base class for action results (damage, heal, etc.)
 */
abstract class ActionEffect
{
  float multiplier;
  abstract void handleEffect(CombatActor user, CombatActor target);
}

ActionEffect loadJSONActionEffect(JSONObject json)
{
  String type = json.getString("type");
  ActionEffect effect;
  if(type.equals("PhysicalDamage"))
  {
    effect = new PhysicalDamageActionEffect(json.getInt("damage_min"),json.getInt("damage_max"));
  }
  else if(type.equals("MagicalDamage"))
  {
    effect = new MagicalDamageActionEffect(json.getInt("damage_min"),json.getInt("damage_max"));
  }
  else if(type.equals("Healing"))
  {
    effect = new HealingActionEffect(json.getInt("healing_min"),json.getInt("healing_max"));
  }
  else if(type.equals("StatusChange"))
  {
    effect = new StatusChange(json.getJSONArray("status_effects"));
  }
  else
  {
    effect = new NullActionEffect();
  }
  effect.multiplier = json.getFloat("multiplier",1.0f);
  return effect;
}

/*
 * Place holder to prevent crashes
 */
class NullActionEffect extends ActionEffect
{
  void handleEffect(CombatActor user, CombatActor target)
  {
    println("*** Null effect for " + user.name + " ***");
  }
}

/*
 * ActionEffect that causes physical damage to the target
 */
class PhysicalDamageActionEffect extends ActionEffect
{
 int damage_min, damage_max;
 
 PhysicalDamageActionEffect(int d_min, int d_max)
 {
   damage_min = d_min;
   damage_max = d_max;
 }
 
 void handleEffect(CombatActor user, CombatActor target)
 {
   float damage;
   damage = (
       user.stats.physical_attack + random(damage_min,damage_max) * multiplier
       ) - target.stats.physical_defense;

   target.stats.hp_current -= int(damage);
 }
}

/*
 * ActionEffect that causes magical damage to the target
 */
class MagicalDamageActionEffect extends ActionEffect
{
 int damage_min, damage_max;
 
 MagicalDamageActionEffect(int d_min, int d_max)
 {
   damage_min = d_min;
   damage_max = d_max;
 }
 
 void handleEffect(CombatActor user, CombatActor target)
 {
   float damage;
   damage = (
       user.stats.magic_attack + random(damage_min,damage_max) * multiplier
       ) - target.stats.magic_defense;

   target.stats.hp_current -= int(damage);
 }
}

/*
 * ActionEffect that heals target based on user's magic
 */
class HealingActionEffect extends ActionEffect
{
 int healing_min, healing_max;
 
 HealingActionEffect(int h_min, int h_max)
 {
  healing_min = h_min;
  healing_max = h_max;
 }
 
 void handleEffect(CombatActor user, CombatActor target)
 {
   float heal;
   heal = user.stats.magic_attack + random(healing_min,healing_max) * multiplier;
   user.stats.hp_current = constrain(user.stats.hp_current+int(heal),0,user.stats.hp_max); // only self heals right now
 }
}

/*
 * ActionEffect that changes target's status somehow
 */
class StatusChange extends ActionEffect
{
 JSONArray effects;

 StatusChange(JSONArray e)
 {
   effects = e;
 }
 
 void handleEffect(CombatActor user, CombatActor target)
 {
  for(int i=0; i<effects.size(); i++)
  {
    JSONObject status = effects.getJSONObject(i);
    target.stats.status_effects.put(status.getString("name"), status.getBoolean("state"));
  }
 }
}
