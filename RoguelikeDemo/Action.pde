/**
 * An action with 3 states, each having a duration
 * States
 * - activating: period before any effect happens (no other actions may be used)
 * - in use: period where the effect is active and occupying character (no other actions may be used)
 * - cooldown: period after use when action is unusable (other actions may be used)
 */
class Action
{
  //// constants
  final static int READY = 0;
  final static int ACTIVATING = 1;
  final static int IN_USE = 2;
  final static int COOLDOWN = 3;
  
  int activation_time;  // time from selection to action occuring
  int duration;  // time action takes to complete
  int cooldown_time;  // time from action occuring until usable again
  int state;  // which state the action is currently in
  int time;  // local time counter
  int max_distance; // how far away target can be; 
  String name;
  ActionEffect effect;
  
  private CombatActor user, target;
  
  Action(JSONObject json)
  {
    activation_time = json.getInt("activation_time");
    duration = json.getInt("duration");
    cooldown_time = json.getInt("cooldown_time");
    state = READY;
    name = json.getString("name");
    effect = loadJSONActionEffect(json.getJSONObject("effect"));
    max_distance = json.getInt("max_distance");
  }
  
  void update()
  {
    if(state != READY)
    {
      time--;
    }
    
    if(time == 0)
    {
      switch(state)
      {
         case ACTIVATING:
             state = IN_USE;
             time = duration;
           break;
         case IN_USE:
             action();
             cooldown();
             user.canAct = true;
           break;
         case COOLDOWN:
             state = READY;
           break;
      }
    }
    
  }
  
  void cooldown()
  {
    state = COOLDOWN;
    time = cooldown_time;
  }
  
  void activate(CombatActor u, CombatActor t)
  {
    user = u;
    target = t;
    if(state == READY && user.canAct)
    {
      state = ACTIVATING;
      time = activation_time;
      user.canAct = false;
    }
  }
  
  private void action()
  {
    effect.handleEffect(this.user,this.target);
    // testing only
    /*
    println(this.user.name + " used " + this.name + " on " + this.target.name);
    println(this.user.name + " HP: " + this.user.stats.hp_current + ", " + this.target.name + " HP: " + this.target.stats.hp_current);
    
    if(this.target.stats.hp_current <= 0)
      {
       this.target.stats.status_effects.put("dead",true);
      }
      if(this.target.stats.status_effects.get("dead"))
      {
       println(this.target.name + " is dead!");
      }
      
      */
    }
}
