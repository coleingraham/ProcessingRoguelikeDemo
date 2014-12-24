/*
 * Keeps track of a character's stats
 */
class CharacterSheet
{
  int hp_current = 100;
  int hp_max = 100;
  int hp_max_base = 100;
  int physical_attack = 1;
  int physical_attack_base = 1;
  int magic_attack = 1;
  int magic_attack_base = 1;
  int physical_defense = 1;
  int physical_defense_base = 1;
  int magic_defense = 1;
  int magic_defense_base = 1;
  HashMap<String,Boolean> status_effects;
  
  CharacterSheet(){
    status_effects = new HashMap<String,Boolean>();
//    status_effects.put("dead",false);
  }
  
}

/**
 * Helper class to deal with converting stat points to actual values
 */
class StatAllocationSystem
{
//  final HashMap<String,Integer> statNames = createMap();
//  
//  private HashMap createMap()
//  {
//    HashMap<String,Integer> m = new HashMap<String,Integer>();
//    m.put("health",0);
//    m.put("atack",1);
//    m.put("defense",2);
//    m.put("magic attack",3);
//    m.put("magic defense",4);
//    m.put("movement speed",5);
//    m.put("sight range",6);
//    return m;
//  }
  
  final int[] maxPoints = {10,10,10,10,10,8,6};
  
  // stat value calculation
  final float[] statGrowth = {9,2,2,2,2,0.005,1};
  
  final float[] statBases = {10,0,0,0,0,0.06,3};
  
  /**
   * Calculates the actual stat value based on the current number of stat points allocated
   */
  void calcStatValue(StatSheet sheet)
  {
    for(int i=0; i<sheet.statValues.length; i++)
    {
      sheet.statValues[i] = (sheet.statPoints[i] + sheet.statBonuses[i]) * statGrowth[i] + statBases[i];
    }
  }
  
  /**
   * Calculates number of unused stat points
   */
  void calcUnusedPoints(StatSheet sheet)
  {
    int value = sheet.totalPoints;
    
    for(int i=0; i<sheet.statPoints.length; i++)
    {
      value -= sheet.statPoints[i];
    }
    
    sheet.unusedPoints = value;
  }
  
  // get stat values from a stat sheet
  
  int getHealth(StatSheet sheet)
  {
    return floor(sheet.statValues[0]);
  }
  
  int getAttack(StatSheet sheet)
  {
    return floor(sheet.statValues[1]);
  }
  
  int getDefense(StatSheet sheet)
  {
    return floor(sheet.statValues[2]);
  }
  
  int getMagAttack(StatSheet sheet)
  {
    return floor(sheet.statValues[3]);
  }
  
  int getMagDefense(StatSheet sheet)
  {
    return floor(sheet.statValues[4]);
  }
  
  float getSpeed(StatSheet sheet)
  {
    return sheet.statValues[5];
  }
  
  int getSight(StatSheet sheet)
  {
    return floor(sheet.statValues[6]);
  }
  
  StatSheet randomStatSheet(int tPoints)
  {
    StatSheet s = new StatSheet();
    s.totalPoints = tPoints;
    int selection;
    calcUnusedPoints(s);
    
    while(s.unusedPoints > 0)
    {
      selection = int(random(7));
      calcUnusedPoints(s);

      s.statPoints[selection] = constrain(
      s.statPoints[selection] + 1,
      0,
      maxPoints[selection] - s.statBonuses[selection]
      );
    }
    
    return s;
  }
}

class StatSheet
{
  int totalPoints = 32;
  int unusedPoints = 0;
  int[] statPoints = {0,0,0,0,0,0,0}; // allocated points
  int[] statBonuses = {0,0,0,0,0,0,0}; // any bonuses
  float[] statValues = {0,0,0,0,0,0,0}; // the values calculated by the stat points
  
  StatSheet()
  {
    
  }
  
}
