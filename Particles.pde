int   root_x          = 1024/2;
int   root_y          = 20;

int   LEVEL_SPACING   = 25;
float X_STRETCH       = 0.8;
int   MAX_LEVELS      = 5;

int   BALL_SIZE       = 10;
//int   BALLS           = 1;
int   balls_desired    = 50;
int   balls_active    = 10;
int   MAX_BALLS       = 2000;

Ball[] balls     = new Ball[MAX_BALLS];
int[]  histogram = new int[MAX_LEVELS];


void setup() {
  size(1024, 700);
  
  for ( int i=MAX_BALLS; i!=0; balls[--i] = new Ball() );

 
  
  reset();
} 

void reset() {
  
  // zero the stats
  for(int i=0; i<MAX_LEVELS;i++) {
    histogram[i] = 0;
  }
  
  // drop a few balls
  for (int i=0; i<=balls_active; balls[i++].drop() );
}
  
void draw () {
  

  if (balls_desired < MAX_BALLS && balls_active < balls_desired ) {
    // find an inactive ball and drop it
    for (int i=0; i<MAX_BALLS; i++) {
      if (!balls[i].active) {
        balls[i].drop();
        balls_active++;
        break;
      }
    }
    //balls[balls_active++].drop();
  }
  
  background(0);
  
  // the bumpers
  fill(64);
  stroke(32);
  for (int i=0; i<MAX_LEVELS-1; i+=2) {
    for (int j=0; j<i+1; j++) {
      bumper(root_x + int((j-i/2)*LEVEL_SPACING * X_STRETCH * 2), root_y + LEVEL_SPACING * (i+1) + BALL_SIZE);
    }
  }
  for (int i=1; i<MAX_LEVELS-1; i+=2) {
    for (int j = 0; j<i+1; j++) {
      bumper(root_x + int((j-i/2-0.5) * LEVEL_SPACING * X_STRETCH *2), root_y + LEVEL_SPACING * (i+1) + BALL_SIZE);
    }
  }
  
  stroke(128);
  int bin_x = root_x;
  int bin_y = root_y + MAX_LEVELS * LEVEL_SPACING + LEVEL_SPACING * 2;
  int bin_s = int(LEVEL_SPACING * X_STRETCH);

  line(bin_x - bin_s * MAX_LEVELS, bin_y, 
       bin_x + bin_s * MAX_LEVELS, bin_y);
  
  // accumulator display
  int all = 0;
  for (int i=0; i<MAX_LEVELS; i++) { 
    all += histogram[i];
  }

  if (all > 0) {
    fill(0);
    for (int i=0;i<MAX_LEVELS; i++) {
     
      fill(color(histogram[i]*512/all, 50, 50, 128));
      rect(bin_x + (bin_s * (2*i+1 - MAX_LEVELS)) - bin_s,  
            bin_y,
            bin_s * 2,
            800 * histogram[i] / all);
    }
  }
  
  if (all > 30) {
    //reset();
  }
  
  
  // and the balls
  for (Ball b: balls) {
    if (b.active) {
      b.update();
      b.display();
    }
  }
  
  // dash board
  stroke(255);
  fill(128);
  text("Balls Active:", 20, 20); text(str(balls_active), 100, 20);
  text("Balls Desired:", 20, 40); text(str(balls_desired), 100, 40);
  text("Counted:", 20, 60); text(str(all), 100, 60);
}

void keyPressed() {
  if (key == '+') {
    balls_desired++;
  }
}
int bumper_width = 6;
int bumper_height = 24;

void bumper(int x, int y) {
  triangle(x, y, x + bumper_width, y + bumper_height, x - bumper_width, y + bumper_height);
}


PVector left  = new PVector(-X_STRETCH, 1);
PVector right = new PVector(+X_STRETCH, 1);
PVector down  = new PVector(0, 1);

class Ball {

  PVector  direction;
  float    levels = MAX_LEVELS;
  float    fall;
  float    speed;
  int      rights;
  boolean  active = false;
  color    c;
  float    x;
  float    y;

  Ball() {
  }
  
  void drop() {
    levels = MAX_LEVELS;
    rights = 0;
    fall   = 0;
    active = true;
    
    x = 0;
    y = 0;
    
    direction = down;
    speed = random(0.5, 1.0);
    c = color(random( 5,10), random(100, 255), random(100, 255), 128);
  }
  
  public void update() {
    
    if ( fall >= LEVEL_SPACING) {
      fall = 0;
      levels --;
      
      // 
      
      if (levels == -1) {
        histogram[rights] ++;
        active = false;
        balls_active--;
        //drop();
      }
      else {
        
        if( levels == 0) {
          direction = down;
        } 
        else {
      
        if (random(1) <= 0.5) {
          direction = left; 
        }
        else {
          direction = right;
          rights++;
        }  
      }
      
      }
      fall = 0;
    }
    
    x += direction.x * speed;
    y += direction.y * speed;
    fall += direction.y * speed;    
  }
  
  void display() {
    fill(c);
    stroke(64);
    ellipse(root_x + x, root_y + y, BALL_SIZE, BALL_SIZE);
  }
}