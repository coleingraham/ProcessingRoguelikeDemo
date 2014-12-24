/**
 * Holds all basic properties for an actor.
 */
abstract class Entity
{
  //// constants
  final int minVisionRadius = 3;
  final int maxVisionRadius = 9;
  
  PVector position;
  float movementSpeed = 0.1;
  int sightRadius = 5;
  int[][] sight;
  int[][] visible;
  boolean moveUp, moveDown, moveLeft, moveRight;
  CombatActor combatActor;
  String id;
  
  Entity(PVector p)
  {
    position = p;
  }
  
  Entity(float x, float y)
  {
    position = new PVector(x,y);
  }
  
  /**
   * Set all stats based on a stat sheet
   */
  void setStatsFromStatSheet(StatSheet sheet)
  {
    sas.calcStatValue(sheet);
    sightRadius = sas.getSight(sheet);
    movementSpeed = sas.getSpeed(sheet);
    combatActor.setMaxHealth(sas.getHealth(sheet));
    combatActor.setAttack(sas.getAttack(sheet));
    combatActor.setDefense(sas.getDefense(sheet));
    combatActor.setMagAttack(sas.getMagAttack(sheet));
    combatActor.setMagDefense(sas.getMagDefense(sheet));
  }
  
  /**
   * Initialize fog of war.
   */
  void initVision(GameMap map)
  {
    visible = new int[map.getHeight()][map.getWidth()];
    updateSight();
  }
  
  void loadCombatActor(String fileName)
  {
    combatActor = new CombatActor(loadJSONObject(fileName),this);
  }
  
  CharacterSheet getCharacterSheet()
  {
    return combatActor.stats;
  }
  
  /**
   * Create the vision mask based on current sightRadius.
   */
  void updateSight()
  {
    sightRadius = constrain(sightRadius,minVisionRadius,maxVisionRadius);
    
    int visionSize = sightRadius * 2 + 1;
    sight = new int[visionSize][visionSize];
    
    for(int x=-sightRadius; x<=sightRadius; x++)
    {
      int h = int(sqrt(sightRadius * sightRadius - x * x));
      
      for(int y=-h; y<=h; y++)
      {
        sight[y+sightRadius][x+sightRadius] = 1;
      }
    }
  }
  
  void movingLeft(boolean value) { moveLeft = value; }
  void movingRight(boolean value) { moveRight = value; }
  void movingUp(boolean value) { moveUp = value; }
  void movingDown(boolean value) { moveDown = value; }
  
  float x() { return position.x; }
  float y() { return position.y; }
  int gridX() { return floor(position.x); }
  int gridY() { return floor(position.y); }
  void moveLeft() { position.x -= movementSpeed; }
  void moveRight() { position.x += movementSpeed; }
  void moveUp() { position.y -= movementSpeed; }
  void moveDown() { position.y += movementSpeed; }
  
  void moveBy(float x, float y)
  {
    position.x += x;
    position.y += y;
  }
  
  void moveTo(float x, float y)
  {
    position.x = x;
    position.y = y;
  }
  
  /**
   * Check to see if the other Entity is both within our sight radius and not behind any walls.
   */
  boolean canSeeEntity(GameMap map, Entity other)
  {
    if(position.dist(other.position) <= sightRadius)
    {
      return inLineOfSight(map,other);
    }
    return false;
  }
  
  /**
   * Check to see if the other Entity is behind any walls.
   */
  boolean inLineOfSight(GameMap map, Entity other)
  {
    int x0, x1, y0, y1;
    
    if(gridX() < other.gridX())
    {
      x0 = gridX();
      y0 = gridY();
      x1 = other.gridX();
      y1 = other.gridY();
    } else {
      x0 = other.gridX();
      y0 = other.gridY();
      x1 = gridX();
      y1 = gridY();
    }
    
    int deltaX = x1 - x0;
    int deltaY = y1 - y0;
    
    int d = 2 * deltaY - deltaX;
    int y = y0;
    int yinc;
    
    if(y0 < y1)
    {
      yinc = 1;
    } else {
      yinc = -1;
    }
    
    for(int x = x0+1; x < x1; x++)
    {
      if(d > 0)
      {
        y = y + yinc;
        d = d + (2*deltaY-2*deltaX);
      } else {
        d = d + (2*deltaY);
      }
      if(map.floor[y][x] == GameMap.WALL) { return false; }
    }
    
    return true;
  }
  
  abstract void update(GameMap map);
  
}

/**
 * Represents a player.
 */
class Player extends Entity
{
  
  Player(PVector p)
  {
    super(p);
  }
  
  Player(float x, float y)
  {
    super(x,y);
  }
  
  void update(GameMap map)
  {
    
  }

}

/**
 * Represents an enemy.
 */
class Enemy extends Entity
{
  
  Enemy(PVector p)
  {
    this(p.x,p.y);
  }
  
  Enemy(float x, float y)
  {
    super(x,y);
    movementSpeed = random(0.01,0.05);
    sightRadius = int(random(4,6));
  }
  
  void update(GameMap map)
  {
    if(canSeeEntity(map,map.getFocusEntity()))
    {
      if(gridX() < map.getFocusEntity().gridX() && canSeeEntity(map,map.getFocusEntity()) ) { movingRight(true); } else { movingRight(false); }
      if(gridX() > map.getFocusEntity().gridX() && canSeeEntity(map,map.getFocusEntity()) ) { movingLeft(true); } else { movingLeft(false); }
      if(gridY() < map.getFocusEntity().gridY() && canSeeEntity(map,map.getFocusEntity()) ) { movingDown(true); } else { movingDown(false); }
      if(gridY() > map.getFocusEntity().gridY() && canSeeEntity(map,map.getFocusEntity()) ) { movingUp(true); } else { movingUp(false); }
    } else {
      float r = 0.5;
      if(noise(frameCount*0.1) < r) { movingRight(true); } else { movingRight(false); }
      if(noise(frameCount*0.1 + 1000) < r) { movingLeft(true); } else { movingLeft(false); }
      if(noise(frameCount*0.1 + 2000) < r)  { movingDown(true); } else { movingDown(false); }
      if(noise(frameCount*0.1 + 3000) < r ){ movingUp(true); } else { movingUp(false); }
    }
    
    
    // combat
    boolean canAct = true;
  
    // sometimes won't act
    if (random(1.0) > 0.2)
    {
      canAct = false;
    }
  
    for (int i=0; i<combatActor.actions.length; i++)
    {
      if (combatActor.actions[i].state == Action.ACTIVATING ||
        combatActor.actions[i].state == Action.IN_USE)
      {
        canAct = false;
        break;
      }
    }
  
    if(canAct)
    {
      int i = int(random(0, combatActor.actions.length));
      if (
      combatActor.actions[i].state == Action.READY &&
      dist(map.getFocusEntity().gridX(),map.getFocusEntity().gridY(),gridX(),gridY()) <= combatActor.actions[i].max_distance
      )
      {
        combatActor.actions[i].activate(this.combatActor, map.getFocusEntity().combatActor);
      }
    }
  }

}
