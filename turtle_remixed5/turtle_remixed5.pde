import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;



// Creative Coding - Assignment 1
//
// turtle_remixed -> does a "Hilbert" curve and draws it, and also does other things like change the background
//                                 and play instruments (badly)
// - Jonathan Tse
//
//         rips a lot of stuff from Luke's turtle2 code from the first class
//         adds a frameRate() to control speed and ability to change frameRate value by pressing F or J.
//         and some sound stuff with drum and guitar loops, D for drums, G for guitar, and B for both.
//


// audio stuff
Minim minim;
//AudioOutput out;

AudioPlayer [] drums; // array to hold all of the drum samples
AudioPlayer [] guitar; // array for guitar samples
int drum_num = 0; // array value for drum array. randomized.
int guitar_num = 0; // array val for guitar
String instrument = "drums"; // determines which instrument to play (maybe both?); [yes, both!]

//float note_counter = 0.0; // first parameter for playNote(), represents the startTime
//float duration = 1.0; // length of the note
//float frequency; // frequency of the note



// TURTLE STUFF:
float x, y; // the current position of the turtle
float currentangle = 0; // which way the turtle is pointing
float step = 20; // how much the turtle moves with each 'F'
float speed = 5; // the rate at which the path will be drawn
float angle = 90; // how much the turtle turns with a '-' or '+'
int whereinstring = 0; // where in the L-system are we drawing right now?

// GRAPHICS STUFF;
float r, g, b, a; // some color shit
float radius; // width of circle
float bg_r, bg_g, bg_b; // background color values

// LINDENMAYER STUFF (L-SYSTEMS)
String thestring = "A"; // "axiom" or start of the string
int numloops = 5; // how many iterations of the L-system to pre-compute

//---------------------------stuff I did---------------------------------------

// timer setup
int now; // stores the last time code was "paused"
int wait_time = 10; // amount of time to wait

// THIS RUNS WHEN WE HIT GO
void setup()
{
  frameRate(speed); // controls the rate of drawing things
  size(800, 600); // this is the size of the window
  background(255); // background to white
  stroke(0, 0, 0, 255); // draw in black
  
  rectMode(CENTER); // changing the ellipses to rectangles just cuz, but keeping the functionality.
  
  minim = new Minim(this); //initializing the... sound engine, i guess.
  
  drums = new AudioPlayer[7]; //initialzing all of the sound files.
  drums[0] = minim.loadFile("bassdrum5.wav");
  drums[1] = minim.loadFile("bongo4.wav");
  drums[2] = minim.loadFile("hihat9.wav");
  drums[3] = minim.loadFile("hihat99.wav");
  drums[4] = minim.loadFile("kettledrum8.wav");
  drums[5] = minim.loadFile("kickdrum3.wav");
  drums[6] = minim.loadFile("snaredrum6.wav");
  
  guitar = new AudioPlayer[7];
  guitar[0] = minim.loadFile("Strat F- 71.wav");
  guitar[1] = minim.loadFile("Strat F- 72.wav");
  guitar[2] = minim.loadFile("Strat F- 73.wav");
  guitar[3] = minim.loadFile("Strat F- 74.wav");
  guitar[4] = minim.loadFile("Strat F- 75.wav");
  guitar[5] = minim.loadFile("Strat F- 76.wav");
  guitar[6] = minim.loadFile("Strat F- 77.wav");
  
  
  // start the x and y position at lower-left corner
  x = 0;
  y = height-1;
  
  // COMPUTE THE L-SYSTEM
  
  println(thestring);
  for(int i = 0;i<numloops;i++) {
    thestring = lindenmayer(thestring); // do the stuff to make the string
     //println(thestring);
  }
  
}

// DO THIS EVERY FRAME
void draw()
{
  /* ------------WOW, map() didn't play well with the Lindemayer generator at all-----------------
  speed = map(mouseX, 0, width, 0, 10);
  frameRate(speed);
  //out.setTempo(speed);
  
  step = map(mouseY, 0, height, 0, 100);
  */
  frameRate(speed);
  
  if(keyPressed) {
    
    if (key == 'f' || key == 'F') {
      speed++;
    }
    if (key =='j' || key == 'J') {
      speed--;
    }
    if (key == 'g' || key == 'G') {
      instrument = "guitar";
    }
    if (key == 'd' || key == 'D') {
      instrument = "drums";
    }
    if (key == 'b' || key == 'B') {
      instrument = "both";
    }
  }
  
  
  
  // draw the current character in the string:
  drawIt(thestring.charAt(whereinstring)); 
  
  // increment the point for where we're reading the string
  whereinstring++;
  if(whereinstring>thestring.length()-1) whereinstring = 0;

}

// interpret an L-system
String lindenmayer(String s)
{
  String outputstring = ""; // start a blank output string
  
  // go through the string, doing rewriting as we go
  for(int i=0;i<s.length();i++)
  {
    if(s.charAt(i)=='A')
    {
       outputstring+="-BF+AFA+FB-";
    }
    else if(s.charAt(i)=='B')
    {
       outputstring+="+AF-BFB-FA+";      
    }
    else
    {
       outputstring+= s.charAt(i); 
    }

  }
  
  return(outputstring); // send out the modified string
}

// this is a custom function that draws turtle commands
void drawIt(char k)
{
   if(k=='F') // draw forward
   {
    // float addition = step/speed;
    // for (int i = 0; i < step; i+= addition) {
       
       float x1 = x + step*cos(radians(currentangle));
       float y1 = y + step*sin(radians(currentangle));
       line(x, y, x1, y1); // draw the line
       ellipse(x,y,2, 2);
       x = x1;
       y = y1;    
       
      if (instrument == "guitar" || instrument == "both") {
         guitar[guitar_num].pause(); // turn off the previous sound before changing to a new sample
         guitar_num = round(random(0, 6)); // randomly choose a sample to play
         // println(drum_num);
         guitar[guitar_num].play(); //play the sample
         guitar[guitar_num].loop(); // for whatever reason, Minim has issues with certain files and replaying them unless you loop.
       }
       if (instrument == "drums") {
         for (int i = 0; i < 7; i++) {
           guitar[i].pause(); // turn off all sounds when guitars are turned off
         }
       }
       
    // }
    /* -------attempt to make notes using Minim's AudioOutput system, with no luck-----------
     frequency = random(0, 200);
     out.playNote(note_counter, duration, frequency);
     out.resumeNotes();
     out.pauseNotes();
     note_counter++;
     
     println(note_counter + ",  " + duration + ", " + frequency);
     */
     /*
     if(x>width-1) x=0;
     if(x<0) x=width-1;
     if(y>height-1) y=0;
     if(y<0) y=height-1;
     */
     
   }
   else if(k=='+') // turn right
   {
     currentangle+=angle;
   }
   else if(k=='-') // turn left
   {
     currentangle-=angle;     
   }
   
   
  // draw the other crazy stuff:
  
  // give me some random values
  
    
    r = random(128, 255);
    g = random(0, 192);
    b = random(0, 50);
    a = random(50, 100);
  
   
    radius+= random(0, 15);
    radius+= random(0, 15);
    radius+= random(0, 15);
    radius = radius/4;
    // draw the stuff
    fill(r, g, b, a); // interior fill color
    rect(x, y, radius, radius); // circle that chases the mouse

     if (instrument == "drums" || instrument == "both") {
         drums[drum_num].pause(); //turn off sounds before playing a new sample
         drum_num = round(random(0, 6)); //randomly choose sample
         // println(drum_num);
         drums[drum_num].play(); // play it
         drums[drum_num].loop();// loop() itttttttt
     }
     
     if (instrument == "guitar") {
         for (int i = 0; i < 7; i++) {
          drums[i].pause(); // and then turn the noise off
         }
       }
       
    
   
}

