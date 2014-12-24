import java.util.concurrent.ConcurrentHashMap;

// settings
int minRoomSize = 15;
int maxRoomSize = 50;

int halfWidth, halfHeight;

// this should probably stay global since it's user input
boolean moveUp, moveDown, moveLeft, moveRight;

//// map vars
// map of the room
GameMap map;

// the renderer for the map
MapRenderer renderer;

// text
PFont digitalFont, scriptFont;

Entity target;
ArrayList<String> targets;
int targetIndex = 0;

// this is an awful way to handle this that is only because of how Processing doesn't let you use static class fields
StatAllocationSystem sas = new StatAllocationSystem();

int testStatPointLevel = 16;

void setup()
{
  size(displayWidth,displayHeight,P3D);
//  size(displayWidth/2,displayHeight/2,P3D);
  frameRate(60);
  smooth();
  noCursor();
  stroke(100);
  
  scriptFont = createFont("AnonymicePowerline-Bold-20.vlw",20);
  
  halfWidth = int(width*0.75);
  halfHeight = halfWidth;//height/2;
  
  renderer = new DebugMapRenderer();
  
  makeRoom();
  
  targets = new ArrayList<String>();

}

void draw()
{
  update();
  background(0);
  drawRoom();
  drawHUD();
}

void makeRoom()
{
//  gameRoom.makeRoom();
  int x = int(random(minRoomSize,maxRoomSize));
  int y = int(random(minRoomSize,maxRoomSize));
  
  if(random(1.0) < 0.5)
  {
    map = new GameMap(x,y,new RectanglularMap());
  } else {
    map = new GameMap(x,y,new BrownianMap());
  }
  renderer.init(600,600);
  
  Player p = new Player(map.getRandomSpawnLocation());
  p.loadCombatActor("Hero.combatActor");
  p.id = p.combatActor.name;
  p.setStatsFromStatSheet(sas.randomStatSheet(testStatPointLevel));
  map.addFocusEntity(p);
  
  Enemy e;
  for(int i=0; i<int(random(1,10)); i++)
  {
    e = new Enemy(map.getRandomSpawnLocation());
    if(random(1) < 0.5)
    {
      e.loadCombatActor("Dude.combatActor");
    } else {
      e.loadCombatActor("Bill.combatActor");
    }
    e.id = e.combatActor.name + " " + i;
    e.setStatsFromStatSheet(sas.randomStatSheet(testStatPointLevel));
    map.addEntity(e);
  }
  
  target = null;
}

void drawHUD()
{
  int a = 150;
  int x = 0;
  int y=0;
  // panel
  noStroke();
  fill(0,a);
  rect(x+2,y+2,220,150);
  stroke(150,a);
  fill(0,150,200,a);
  rect(x,y,220,150);
  // player name
  stroke(0,a);
  line(10,25,210,25);
  textFont(scriptFont);
  textAlign(LEFT,TOP);
  fill(0,a);
  x = 10;
  text(map.playerName,x+2,y+2);
  fill(255,a);
  text(map.playerName,x,y);
  // health bar
  noStroke();
  fill(0,a);
  y = 30;
  rect(x+2,y+2,200,20);
  fill(50,200,0,a);
  stroke(255,a);
  int currentHP = map.getFocusEntity().getCharacterSheet().hp_current;
  int maxHP = map.getFocusEntity().getCharacterSheet().hp_max;
  rect(x,y,map(currentHP,0,maxHP,0,200),20);
  fill(0,a);
  String t = "HP: " + currentHP + "/" + maxHP;
  text(t,x+2,y-1);
  fill(255,a);
  text(t,x,y-3);
  
  y = 55;
  // draw actions
  for(int i=0; i<map.getFocusEntity().combatActor.actions.length; i++)
  {
    noStroke();
    float time;
    if(map.getFocusEntity().combatActor.actions[i].state == Action.COOLDOWN)
    {
      time = map(
      map.getFocusEntity().combatActor.actions[i].time, 
      map.getFocusEntity().combatActor.actions[i].cooldown_time,0, 
      0,200
      );
      fill(200,0,0,a);
    } else if(map.getFocusEntity().combatActor.actions[i].state == Action.ACTIVATING)
    {
      time = map(
      map.getFocusEntity().combatActor.actions[i].time, 
      0,map.getFocusEntity().combatActor.actions[i].activation_time, 
      0,200
      );
      fill(0,0,255,a);
    } else if(map.getFocusEntity().combatActor.actions[i].state == Action.READY)
    {
      time = 200;
      if(target != null && dist(map.getFocusEntity().gridX(),map.getFocusEntity().gridY(),target.gridX(),target.gridY()) <= map.getFocusEntity().combatActor.actions[i].max_distance)
      {
        fill(0,255,0,a);
      } else {
        fill(150,a);
      }
      if(map.getFocusEntity().combatActor.actions[i].max_distance == 0)
      {
        fill(0,255,0,a);
      }
    } else{
      time = 0;
      fill(0,255,0,a);
    }
    rect(
    x,(y+2)+20*i,time,20);
    noFill();
    stroke(255,a);
    rect(x,(y+2)+20*i,200,20);
    fill(0,a);
    t = ((i+7)%10) + ": " + map.getFocusEntity().combatActor.actions[i].name;
    text(t,x+4,(y+2)+20*i);
    fill(255,a);
    text(t,x+2,y+20*i);
  }
  
  // draw targets
//  x = width/2;
//  y = 20;
//  for(int i=0; i<targets.size(); i++)
//  {
//    textAlign(CENTER,CENTER);
//    fill(0);
//    text(map.getEntity(targets.get(i)).combatActor.name,x+2,y+i*22);
//    if(i == targetIndex)
//    {
//      fill(255,0,0);
//    } else {
//      fill(255);
//    }
//    text(map.getEntity(targets.get(i)).combatActor.name,x,y+i*20);
//  }
}

void drawRoom()
{
  noStroke();
  pushMatrix();
  translate(width/2,height/2);
  rotateX(PI/6.0);
  beginShape();
  texture(renderer.show(map));
  vertex(-halfWidth,-halfHeight,0,0);
  vertex(halfWidth,-halfHeight,renderer.getWidth(),0);
  vertex(halfWidth,halfHeight,renderer.getWidth(),renderer.getHeight());
  vertex(-halfWidth,halfHeight,0,renderer.getHeight());
  endShape();
  popMatrix();
}

void update()
{
  updateRoom();
}

void updateRoom()
{
    if(map.getFocusEntity().getCharacterSheet().hp_current <= 0) {
    makeRoom();
  }
  map.update();
  
  if(targets.size() > 0)
  {
    targetIndex = targetIndex % targets.size();
    target = map.getEntity(targets.get(targetIndex));
  } else {
    target = null;//map.getFocusEntity();
  }
  
  if(map.getTile(floor(map.getFocusEntity().position.x),floor(map.getFocusEntity().position.y)) == GameMap.DOOR)
  {
    makeRoom();
  }
  
  // populate a list of possible targest
  targets.clear();
  for(Entity e : map.entities.values())
  {
    if(
    map.getFocusEntity().canSeeEntity(map,e)
    && e != map.getFocusEntity()
    )
    {
      targets.add(e.id);
    }
  }
}

void keyPressed()
{
  switch(key)
  {
    case 'w':
      map.getFocusEntity().movingUp(true);
      break;
    case 'd':
      map.getFocusEntity().movingRight(true);
      break;
    case 's':
      map.getFocusEntity().movingDown(true);
      break;
    case 'a':
      map.getFocusEntity().movingLeft(true);
      break;
    case 'W':
      map.getFocusEntity().movingUp(true);
      break;
    case 'D':
      map.getFocusEntity().movingRight(true);
      break;
    case 'S':
      map.getFocusEntity().movingDown(true);
      break;
    case 'A':
      map.getFocusEntity().movingLeft(true);
      break;
    case '7':
      tryAction(0);
      break;
    case '8':
      tryAction(1);
      break;
    case '9':
      tryAction(2);
      break;
    case '0':
      tryAction(3);
      break;
    case '=':
      if(targets.size() > 0)
      {
        targetIndex = (targetIndex + 1) % targets.size();
      }
      break;
    case '-':
      if(targets.size() > 0)
      {
        targetIndex = (targetIndex - 1) % targets.size();
        if(targetIndex < 0)
        {
          targetIndex = targetIndex + targets.size();
        }
      }
      break;
    
    // cooldown test
    case '1':
      map.getFocusEntity().setStatsFromStatSheet(sas.randomStatSheet(testStatPointLevel));
      map.getFocusEntity().updateSight();
      map.getFocusEntity().combatActor.forceCooldown();
      break;
  }
  
  if(key == CODED)
  {
    switch(keyCode)
    {
      case ESC:
        exit();
        break;
    }
  }
}

void tryAction(int num)
{
  if(target != null)
  {
    if(
    dist(map.getFocusEntity().gridX(),map.getFocusEntity().gridY(),target.gridX(),target.gridY()) <= map.getFocusEntity().combatActor.actions[num].max_distance ||
    map.getFocusEntity().combatActor.actions[num].max_distance == 0
    )
    {
      map.getFocusEntity().combatActor.actions[num].activate(map.getFocusEntity().combatActor,target.combatActor);
    }
    // healing
  } else if(map.getFocusEntity().combatActor.actions[num].max_distance == 0)
  {
    map.getFocusEntity().combatActor.actions[num].activate(map.getFocusEntity().combatActor,map.getFocusEntity().combatActor);
  }
}

void keyReleased()
{
  switch(key)
  {
    case ' ':
      makeRoom();
      break;
    case 'w':
      map.getFocusEntity().movingUp(false);
      break;
    case 'd':
      map.getFocusEntity().movingRight(false);
      break;
    case 's':
      map.getFocusEntity().movingDown(false);
      break;
    case 'a':
      map.getFocusEntity().movingLeft(false);
      break;
    case 'W':
      map.getFocusEntity().movingUp(false);
      break;
    case 'D':
      map.getFocusEntity().movingRight(false);
      break;
    case 'S':
      map.getFocusEntity().movingDown(false);
      break;
    case 'A':
      map.getFocusEntity().movingLeft(false);
      break;
    case 'V':
      map.getFocusEntity().sightRadius++;
      map.getFocusEntity().updateSight();
      break;
    case 'v':
      map.getFocusEntity().sightRadius--;
      map.getFocusEntity().updateSight();
      break;
    case 'P':
      map.getFocusEntity().movementSpeed = constrain(map.getFocusEntity().movementSpeed + 0.01,0.05,0.2);
      break;
    case 'p':
      map.getFocusEntity().movementSpeed = constrain(map.getFocusEntity().movementSpeed - 0.01,0.05,0.2);
      break;
  }
}
