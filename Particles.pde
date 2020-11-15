int   root_x          = 1024/2;
int   root_y          = 20;

int   LEVEL_SPACING   = 35;
float X_STRETCH       = 0.8;

int   levels          = 5;
int   MAX_LEVELS      = 15;

int   BALL_SIZE       = 10;
int   balls_desired   = 2;
int   balls_active    = 2;
static int   MAX_BALLS       = 500;

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
  fill(128, 128, 0);
  stroke(100);
  for (int i=0; i<levels-1; i++) {
    for (int j=0; j<i+1; j++) {
      bumper(root_x + int(
                           (j * 2 - i) * LEVEL_SPACING * X_STRETCH
                      ),
             root_y + LEVEL_SPACING * (i+1) + BALL_SIZE);
      //bumper(root_x + int(j-i/2)*LEVEL_SPACING * X_STRETCH * 2, root_y + LEVEL_SPACING * (i+1) + BALL_SIZE);
    }
  }
  
  
  stroke(128);
  int bin_x = root_x;
  int bin_y = root_y + levels * LEVEL_SPACING + LEVEL_SPACING * 1;
  int bin_s = int(LEVEL_SPACING * X_STRETCH);

  line(bin_x - bin_s * levels, bin_y, 
       bin_x + bin_s * levels, bin_y);
  
  // accumulator display
  int all = 0;
  float sum = 0;
  for (int i=0; i<levels; i++) { 
    all += histogram[i];
    sum += histogram[i] * (float(i)/(levels-1));
  }

  if (all > 0) {
    fill(0);
    for (int i=0;i<levels; i++) {
     
      fill(color(histogram[i]*512/all, 50, 50, 128));
      rect(bin_x + (bin_s * (2*i+1 - levels)) - bin_s,  
            bin_y,
            bin_s * 2,
            800 * histogram[i] / all);
    }
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
  
  text("Normal Distribution Generator - v1.0", 20, 20); 
  text("Balls:", 20, 50); text(str(balls_desired+1), 100, 50); text("[B] more, [b] less", 135, 50);
  text("Levels:", 20, 70); text(str(levels), 100, 70);       text("[L] more, [l] less", 135, 70);
  
  
  if (all > 0) {
    text("n:", 20, 100); text(str(all), 100, 100);
    text("mean:", 20, 120); text(str(sum/all), 100, 120);
    //text("sd():", 20, 140); text(str(3.141), 100, 140);
  }
  
  

}

void keyPressed() {
  if (key == 'B' ) {
    if (balls_desired == 0) 
       balls_desired = 1;
    else
      balls_desired = ceil(float(balls_desired) * 1.05);
    if (balls_desired >= MAX_BALLS) balls_desired = MAX_BALLS-1;
  }
  if (key == 'b' && balls_desired > 0)         balls_desired /= 1.1;
  if (key == 'L' && levels < MAX_LEVELS)       { levels++; reset(); }
  if (key == 'l' && levels > 0)                { levels--; reset(); }
}

int bumper_width = 10;
int bumper_height = 12;

void bumper(int x, int y) {
  triangle(x, y -2 , x + bumper_width, y + bumper_height, x - bumper_width, y + bumper_height);
}


PVector left  = new PVector(-X_STRETCH*2, 1);
PVector right = new PVector(+X_STRETCH*2, 1);
PVector down  = new PVector(0, 1.5);

class Ball {

  PVector  direction;
  float    levels_remaining = levels;
  float    fall;
  float    speed;
  int      rights;
  boolean  active = false;
  float    r, g, b;
  color    c;
  float    x;
  float    y;

  Ball() {
  }
  
  void drop() {
    levels_remaining = levels;
    rights = 0;
    fall   = 0;
    active = true;
    
    x = 0;
    y = 0;
    
    direction = down;
    speed = random(0.5, 1.0);
    
    r = random(5,10);
    g = random(100, 255);
    b = random(100, 255);
    c = color(r, g, b, 128);
  }
  
  public void update() {
    
    if (fall >= LEVEL_SPACING / 2) {
      direction = down;
    }  
     
    if ( fall >= LEVEL_SPACING) {
      fall = 0;
      levels_remaining --;
      
      // 
      
      if (levels_remaining == -1) {
        histogram[rights] ++;
        active = false;
        balls_active--;
        //drop();
      }
      else {
        
        if( levels_remaining == 0) {
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