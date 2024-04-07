//----------------------------------------------------------------------------
// name: playmovie.pde
// desc: playing a video controlled by OSC
//       for Tess and Andrew (and anyone else working with video in
//       in Processing + ChucK)
//
// to play: run this with playmovie.ck
//
// author: Ge Wang (https://ccrma.stanford.edu/~ge/)
// date: Winter 2022
//----------------------------------------------------------------------------
 
import oscP5.*;
import netP5.*;
import processing.video.*;

// OSC object
OscP5 oscP5;
NetAddress myRemoteLocation;

// the movie object
Movie myMovie;

// most recent parameters values received from OSC
int which;
float playhead;
float rate;

// set up
void setup()
{
  // full screen
  // fullScreen();
  // window size
  size(640,352);
  // frame rate
  frameRate(60);

  // instantiate movie
  myMovie = new Movie(this, "canardo.mp4");
  // volume (tho this doesn't seem to work unless repeated below)
  myMovie.volume(0);
  // start playing?
  //myMovie.play();
 
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

// draw next frame
void draw()
{
  background(0);  
  image(myMovie, 0, 0);
}

void movieEvent(Movie m)
{
  m.read();
}

// can be used to send OSC
void mousePressed()
{
}

// handles incoming OSC messages
void oscEvent(OscMessage theOscMessage)
{
  /* print the address pattern and the typetag of the received OscMessage */
  // print("### received an osc message.");
  // print(" addrpattern: "+theOscMessage.addrPattern());
  // println(" typetag: "+theOscMessage.typetag());
    if(theOscMessage.checkAddrPattern("/foo/playmovie")==true)
  {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("iff"))
    {
        // get which
        which = theOscMessage.get(0).intValue();
        // get the playhead (by percentage)
        playhead = theOscMessage.get(1).floatValue();
        // get the playback rate
        rate = theOscMessage.get(2).floatValue();
        // seek to percentage
        myMovie.jump(playhead * myMovie.duration());
        // set playback rate
        myMovie.speed(rate);
        // silence the audio (if we want to use our own, e.g., from ChucK)
        myMovie.volume(0);
        // start playing
        myMovie.play();
        // done
        return;
    } 
  }
}
