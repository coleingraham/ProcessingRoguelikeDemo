/**
 * Generates and holds all information for a map.
 */
class GameMap
{
  // ground tile types
  final static int EMPTY = 0;
  final static int WALL = 1;
  final static int GROUND = 2;
  final static int DOOR = 3;
  
  // door directions
  final static int WEST = 0;
  final static int NORTH = 1;
  final static int EAST = 2;
  final static int SOUTH = 3;
  
  // fog of war
  final static int UNSEEN = 0;
  final static int LIT = 1;
  final static int FOG = 2;
  
  //// map variables
  int[][] floor;
  boolean[][] collisions;
  int mapWidth;
  int mapHeight;
  PGraphics buffer;
  ConcurrentHashMap<String,Entity> entities;
  String playerName;
  
  GameMap(int w, int h, MapType t)
  {
    mapWidth = w;
    mapHeight = h;
    floor = new int[mapHeight][mapWidth];
    collisions = new boolean[mapHeight][mapWidth];
    
    floor = t.generate(mapWidth,mapHeight);
    initCollisions();
    
    PVector door = getRandomSpawnLocation();
    floor[floor(door.y)][floor(door.x)] = DOOR;
    
    entities = new ConcurrentHashMap<String,Entity>();
  }
  
  void initCollisions()
  {
    for(int y=0; y<mapHeight; y++)
    {
      for(int x=0; x<mapWidth; x++)
      {
        if(floor[y][x] == WALL) { collisions[y][x] = true; } else { collisions[y][x] = false; }
      }
    }
  }
  
  void addEntity(Entity entity)
  {
    entity.initVision(this);
    entities.put(entity.id,entity);
  }
  
  void addFocusEntity(Entity entity)
  {
    playerName = entity.id;
    addEntity(entity);
  }
  
  PVector getRandomSpawnLocation()
  {
    PVector pos = new PVector(0,0);
    
    
    while(true)
    {
      pos.x = random(0,mapWidth);
      pos.y = random(0,mapHeight);
      
      if(floor[floor(pos.y)][floor(pos.x)] == GROUND) {
        return pos;
      }
    }
  }
  
  Entity getFocusEntity()
  {
    return (Player) getEntity(playerName);
  }
  
  Entity getEntity(String name)
  {
    return entities.get(name);
  }
  
  void removeEntity(String name)
  {
    entities.remove(name);
  }
  
  int[][] getFloor()
  {
    return floor;
  }
  
  int getWidth()
  {
    return mapWidth;
  }
  
  int getHeight()
  {
    return mapHeight;
  }
  
  int getTile(int x, int y)
  {
    return floor[y][x];
  }
  
  void update()
  {
    int px, py;
    // for every Entity
    for(Entity entity : entities.values())
    {
      entity.update(this);
      entity.combatActor.updateActions();
      
//      initCollisions();
      
      px = entity.gridX();
      py = entity.gridY();
      map.collisions[py][px] = true;
      
      // move all entities that are moving and check for collisions
      if(entity.moveUp)
      {
        if(
        !map.collisions[entity.gridY()-1][entity.gridX()] &&
        entity.y() >= entity.gridY()
        )
        {
          entity.moveUp();
        }
      }
      if(entity.moveLeft)
      {
        if(
        !map.collisions[entity.gridY()][entity.gridX()-1] &&
        entity.x() >= entity.gridX()
        )
        {
          entity.moveLeft();
        }
      }
      if(entity.moveDown)
      {
        if(
        !map.collisions[entity.gridY()+1][entity.gridX()] &&
        entity.y() <= entity.gridY()+1
        )
        {
          entity.moveDown();
        }
      }
      if(entity.moveRight)
      {
        if(
        !map.collisions[entity.gridY()][entity.gridX()+1] &&
        entity.x() <= entity.x()+1
        )
        {
          entity.moveRight();
        }
      }
      
      if(entity.gridX() != px || entity.gridY() != py) { map.collisions[py][px] = false; }
      
      ////////
      
      // update vision for every entity
      for(int y=0; y<entity.visible.length; y++)
      {
        for(int x=0; x<entity.visible[y].length; x++)
        {
          switch(entity.visible[y][x])
          {
            case GameMap.LIT:
              entity.visible[y][x] = GameMap.FOG;
              break;
          }
        }
      }
      
      for(int x = -1 * entity.sightRadius; x <= entity.sightRadius; x++)
      {
        for(int y = -1 * entity.sightRadius; y <= entity.sightRadius; y++)
        { 
          switch(entity.sight[y+entity.sightRadius][x+entity.sightRadius])
          {
            case GameMap.LIT:
              entity.visible[constrain(int(entity.position.y)+y,0,entity.visible.length-1)][constrain(int(entity.position.x)+x,0,entity.visible[0].length-1)] = GameMap.LIT;
              break;
          }
        }
      }
      
      // testing damaging player by touch
//      if(
//        entity != getFocusEntity() &&
//        dist(entity.gridX(),entity.gridY(),getFocusEntity().gridX(),getFocusEntity().gridY()) <= 1.5
//      )
//      {
//        map.getFocusEntity().getCharacterSheet().hp_current--;
//      }
      
    }
    
    for(Entity entity : entities.values())
    {
      // remove dead things
      if(entity.getCharacterSheet().hp_current <= 0 && entity != map.getFocusEntity()) {
        target = null;
        collisions[entity.gridY()][entity.gridX()] = false;
        removeEntity(entity.id);
      }
    }
   
    
  }
  
}

/**
 * Superclass for all types of maps to generate
 */
abstract class MapType
{ 
  abstract int[][] generate(int w, int h);
}

/**
 * Generates a rectangular map.
 */
class RectanglularMap extends MapType
{
  int[][] generate(int w, int h)
  {
    int[][] room = new int[h][w];
    boolean[] doors = new boolean[4];
    float innerWALLChance = random(0.03,0.05);
    
    // fill the room
    for(int i=0; i<h; i++)
    {
      for(int j=0; j<w; j++)
      {
        room[i][j] = GameMap.GROUND;
        
        // draw parimater WALLs
        if(i==0 || i==(h-1))
        {
          room[i][j] = GameMap.WALL;
        }
        
        if(j==0 || j==(w-1))
        {
          room[i][j] = GameMap.WALL;
        }
      }
    }
    
    // add random pillars, etc.
    for(int i=2; i<h-4; i++ )
    {
      for(int j=2; j<w-4; j++)
      {
        // chance to have WALL in the center
        if(random(1.0) < innerWALLChance)
        {
          if(random(1.0) < 0.5)
          {
            room[i][j] = GameMap.WALL;
            room[i+1][j] = GameMap.WALL;
            room[i][j+1] = GameMap.WALL;
            room[i+1][j+1] = GameMap.WALL;
          } else {
            room[i][j] = GameMap.WALL;
            room[i+1][j] = GameMap.WALL;
            room[i-1][j] = GameMap.WALL;
            room[i][j+1] = GameMap.WALL;
            room[i][j-1] = GameMap.WALL;
          }
        }
      }
    }
    /*
    // add doors
    for(int i=0; i<doors.length; i++)
    {
      if(random(100) >= 50)
      {
        doors[i] = true;
      } else {
        doors[i] = false;
      }
    }
    
    int pos;
    
    for(int i=0; i<doors.length; i++)
    { 
      switch(i)
      {
        case WEST:  // west WALL
          if(doors[i])
          {
            pos = int(random(2,room.length-2));
            room[pos][0] = DOOR;
            // make sure there's space around the rood for the player(s)
            room[pos][1] = GROUND;
            room[pos-1][1] = GROUND;
            room[pos+1][1] = GROUND;

          }
          break;
        case NORTH:  // north WALL
          if(doors[i])
          {
            pos = int(random(2,room[0].length-2));
            room[0][pos] = DOOR;
            // make sure there's space around the rood for the player(s)
            room[1][pos] = GROUND;
            room[1][pos-1] = GROUND;
            room[1][pos+1] = GROUND;

          }
          break;
        case EAST:  // east WALL
          if(doors[i])
          {
            pos = int(random(2,room.length-2));
            room[pos][room[0].length-1] = DOOR;
            // make sure there's space around the rood for the player(s)
            room[pos][room[0].length-2] = GROUND;
            room[pos-1][room[0].length-2] = GROUND;
            room[pos+1][room[0].length-2] = GROUND;

          }
          break;
        case SOUTH:  // south WALL
          if(doors[i])
          {
            pos = int(random(2,room[0].length-2));
            room[room.length-1][pos] = DOOR;
            // make sure there's space around the rood for the player(s)
            room[room.length-2][pos] = GROUND;
            room[room.length-2][pos-1] = GROUND;
            room[room.length-2][pos+1] = GROUND;

          }
          break;
      }
    }
    */
    return room;
  }
}

/**
 * Generates a brownian map. NEEDS DOORS!!!
 */
class BrownianMap extends MapType
{
  int[][] generate(int w, int h)
  {
    int[][] room = new int[h][w];
    
    for(int y=0; y<h; y++)
    {
      for(int x=0; x<w; x++)
      {
        room[y][x] = GameMap.WALL;
      }
    }
    
    float groundCover = random(0.65,0.75);
    int numGround = int(w*h*groundCover);
    
    int px = int(random(w-1));
    int py = int(random(h-1));
    
    while(numGround > 0)
    {
      if(room[py][px] == GameMap.WALL)
      {
        room[py][px] = GameMap.GROUND;
        numGround--;
      }
      px = constrain(px + round(random(-1,1)), 1, w-2);
      py = constrain(py + round(random(-1,1)), 1, h-2);
    }
    
    return room;
  }
}

/**
 * Interface for all map drawing styles.
 */
abstract class MapRenderer
{
  int tileSize = 30;
  PGraphics buffer;
  int width, height;
  
  void init(int w, int h)
  {
    buffer = createGraphics(w,h,P2D);
    buffer.beginDraw();
    buffer.smooth();
    buffer.endDraw();

    
    this.width = w;
    this.height = h;
  }
  
  int getWidth()
  {
    return this.width;
  }
  
  int getHeight()
  {
    return this.height;
  }
  
  int getTileSize()
  {
    return tileSize;
  }
  
  void setTileSize(int s)
  {
    tileSize = s;
  }
  
  /**
   * Handle all the general camera stuff
   */
  PImage show(GameMap map)
  {
    buffer.beginDraw();
    buffer.ellipseMode(CENTER);
    buffer.translate(
      (buffer.width/2) - (map.getFocusEntity().x() * renderer.tileSize),
      (buffer.height/2) - (map.getFocusEntity().y() * renderer.tileSize)
    );
    buffer.background(0);
    buffer.stroke(0);
    for(int y=0; y<map.getHeight(); y++)
    {
      for(int x=0; x<map.getWidth(); x++)
      {
        if(dist(x,y,map.getFocusEntity().gridX(),map.getFocusEntity().gridY()) < 13)
        {
          rendeTiles(map,x,y);
        }
      }
    }
    
    rendeEntities(map);
    
    buffer.endDraw();
    return buffer;
  }
  
  /**
   * Render each tile of the map to the render buffer.
   */
  abstract void rendeTiles(GameMap map, int x, int y);
  abstract void rendeEntities(GameMap map);
}

/**
 * Draw general debug graphics for any map.
 */
class DebugMapRenderer extends MapRenderer
{ 
  void rendeTiles(GameMap map, int x, int y)
  {
    if(map.getFocusEntity().visible[y][x] == GameMap.LIT || map.getFocusEntity().visible[y][x] == GameMap.FOG)
    {
    switch(map.getFloor()[y][x])
    {
      case GameMap.GROUND:
        buffer.fill(150);
        break;
      case GameMap.WALL:
        buffer.fill(255);
        break;
      case GameMap.DOOR:
        buffer.fill(150,0,0);
        break;
    }

    buffer.rect(tileSize*x,tileSize*y,tileSize,tileSize);
    }
    // fog of war
    if(map.getFocusEntity().visible[y][x] == GameMap.FOG)
    {
      buffer.fill(13,49,106,150);
      buffer.rect(tileSize*x,tileSize*y,tileSize,tileSize);
    }
  }
  
  void rendeEntities(GameMap map)
  {
    // draw entities who are within sight range
    for(Entity entity : map.entities.values())
    {
      if(map.getFocusEntity().canSeeEntity(map,entity))
      {
//        buffer.noFill();
//        buffer.stroke(255,0,0);
//        buffer.ellipse(
//          entity.x()*tileSize,
//          entity.y()*tileSize,
//          entity.sightRadius*tileSize*2,
//          entity.sightRadius*tileSize*2
//        );
        buffer.noStroke();
        buffer.fill(0,200,100,100);
        buffer.rect(tileSize*entity.gridX(),tileSize*entity.gridY(),tileSize,tileSize);
        buffer.fill(0);
        buffer.rect(tileSize*entity.x()-20,tileSize*entity.y()-8,40,3);
        buffer.fill(
          lerpColor(
          color(255,0,0),
          color(0,255,0),
          map(entity.combatActor.stats.hp_current,0,entity.combatActor.stats.hp_max,0.0,1.0)
          )
        );
        buffer.rect(
          tileSize*entity.x()-20,
          tileSize*entity.y()-8,
          map(entity.combatActor.stats.hp_current,0,entity.combatActor.stats.hp_max,0,40),
          3
        );
        buffer.textFont(scriptFont);
        buffer.textAlign(CENTER,CENTER);
        buffer.fill(0);
        buffer.text(entity.combatActor.name,tileSize*entity.x()+2,tileSize*entity.y()-18);
        buffer.fill(255);
        buffer.text(entity.combatActor.name,tileSize*entity.x(),tileSize*entity.y()-20);
        buffer.stroke(0);
        buffer.fill(255,0,0);
        buffer.ellipse(tileSize*entity.x(),tileSize*entity.y(),10,10);
      }/* else {
        buffer.stroke(0);
        buffer.fill(255,0,0);
        buffer.ellipse(tileSize*entity.x(),tileSize*entity.y(),10,10);
      }*/
    }
    
    buffer.fill(0,255,0);
    buffer.ellipse(tileSize*map.getFocusEntity().x(),tileSize*map.getFocusEntity().y(),10,10);
    // draw the vision radius non-tiled
//    buffer.fill(0,255,0,25);
//    buffer.noFill();
//    buffer.stroke(255);
//    buffer.ellipse(
//      map.getFocusEntity().x()*tileSize,
//      map.getFocusEntity().y()*tileSize,
//      map.getFocusEntity().sightRadius*tileSize*2,
//      map.getFocusEntity().sightRadius*tileSize*2
//    );

    // draw target selection
    if(target != null)
    {
      float s = map(sin(map(frameCount%60,0,59,0,TWO_PI)),-1.0,1.0,10,20);
      buffer.noFill();
      buffer.stroke(0);
      buffer.rect(target.x()*tileSize-s+1,target.y()*tileSize-s+1,s*2,s*2);
      buffer.stroke(255,0,0);
      buffer.rect(target.x()*tileSize-s,target.y()*tileSize-s,s*2,s*2);
    }
  }
}
