//-----------------------------------------------------------------------------
// name: receiver-gametra.ck
// desc: gametrak boilerplate code;
//       prints 6 axes of the gametrak tethers + foot pedal button;
//       a helpful starting point for mapping gametrak;
//       recieved over OSC from a different machine
//
// author: Ge Wang (ge@ccrma.stanford.edu), Trijeet Mukhopadhyay (trijeetm@gmail.com)
// date: spring 2022
//-----------------------------------------------------------------------------

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// use port 6449 (or whatever)
6449 => oin.port;
// create an address in the receiver
oin.addAddress( "/gametrak, i f f f f f f f f f f f f f f i" );


// data structure for gametrak
class GameTrak
{
    // id 
    int id;

    // timestamps
    float lastTime;
    float currTime;
    
    // previous axis data
    float lastAxis[6];
    // current axis data
    float axis[6];

    // button status
    int isButtonDown;
}

// gametrack
GameTrak gt;

// spork control
spork ~ receiveRemoteGametrak();

// main loop
while( true )
{
    // print 6 continuous axes -- XYZ values for left and right
    <<< "axes:", gt.axis[0],gt.axis[1],gt.axis[2],
                 gt.axis[3],gt.axis[4],gt.axis[5], gt.isButtonDown >>>;

    // also can map gametrak input to audio parameters around here
    // note: gt.lastAxis[0]...gt.lastAxis[5] hold the previous XYZ values

    // advance time
    100::ms => now;
}

// gametrack handling
fun void receiveRemoteGametrak()
{
    while( true )
    {
        // wait on OSC from remote gametrak as event
        oin => now;

        // grab the next message from the queue. 
        while( oin.recv(msg) )
        { 
            // to track the offset in the type string
            0 => int offset; 

            // expected type string
            // i f f f f f f f f f f f f f f i 
            msg.getInt(offset) => gt.id;
            1 +=> offset;

            msg.getFloat(offset) => gt.lastTime;
            1 +=> offset;

            msg.getFloat(offset) => gt.currTime;
            1 +=> offset;

            // previous axis data
            // 6 x floats      
            for ( int i; i < gt.lastAxis.size(); i++) {
                msg.getFloat(offset + i) => gt.lastAxis[i];
            }
            6 +=> offset;

            // current axis data
            // 6 x floats      
            for ( int i; i < gt.axis.size(); i++) {
                msg.getFloat(offset + i) => gt.axis[i];
            }
            6 +=> offset;
            
            msg.getInt(offset) => gt.isButtonDown;

        }
    }
}
