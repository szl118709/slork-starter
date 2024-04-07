//-----------------------------------------------------------------------------
// name: sender-gametra.ck
// desc: gametrak boilerplate code;
//       prints 6 axes of the gametrak tethers + foot pedal button;
//       a helpful starting point for mapping gametrak;
//       distributed to other machines over OSC
//
// author: Ge Wang (ge@ccrma.stanford.edu), Trijeet Mukhopadhyay (trijeetm@gmail.com)
// date: spring 2022
//-----------------------------------------------------------------------------

// global to determine gametrak ID
1111 => int gametrakID;
0 => float dummmyTimestamp;

// destination host name
"localhost" => string hostname;
// destination port number
6449 => int port;

// check command line
if( me.args() ) me.arg(0) => hostname;
if( me.args() > 1 ) me.arg(1) => Std.atoi => port;

// sender object
OscOut xmit;

// aim the transmitter at destination
xmit.dest( hostname, port );

// z axis deadzone
0 => float DEADZONE;

// which joystick
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// HID objects
// HID = Human Interface Device
Hid trak;
HidMsg msg;

// open joystick 0, exit on fail
if( !trak.openJoystick( device ) ) me.exit();

// print
<<< "joystick '" + trak.name() + "' ready", "" >>>;

// data structure for gametrak
class GameTrak
{
    // timestamps
    time lastTime;
    time currTime;
    
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
spork ~ gametrak();

// main loop
while( true )
{
    // print 6 continuous axes -- XYZ values for left and right
    <<< "axes:", gt.axis[0],gt.axis[1],gt.axis[2],
                 gt.axis[3],gt.axis[4],gt.axis[5] >>>;

    // also can map gametrak input to audio parameters around here
    // note: gt.lastAxis[0]...gt.lastAxis[5] hold the previous XYZ values

    // advance time
    100::ms => now;
}

// gametrack handling
fun void gametrak()
{
    while( true )
    {
        // wait on HidIn as event
        trak => now;
        
        // messages received
        while( trak.recv( msg ) )
        {
            // joystick axis motion
            if( msg.isAxisMotion() )
            {            
                // check which
                if( msg.which >= 0 && msg.which < 6 )
                {
                    // check if fresh
                    if( now > gt.currTime )
                    {
                        // time stamp
                        gt.currTime => gt.lastTime;
                        // set
                        now => gt.currTime;
                    }
                    // save last
                    gt.axis[msg.which] => gt.lastAxis[msg.which];
                    // the z axes map to [0,1], others map to [-1,1]
                    if( msg.which != 2 && msg.which != 5 )
                    { msg.axisPosition => gt.axis[msg.which]; }
                    else
                    {
                        1 - ((msg.axisPosition + 1) / 2) - DEADZONE => gt.axis[msg.which];
                        if( gt.axis[msg.which] < 0 ) 0 => gt.axis[msg.which];
                    }
                }
            }
            
            // joystick button down
            else if( msg.isButtonDown() )
            {
                <<< "button", msg.which, "down" >>>;
                1 => gt.isButtonDown;
            }
            
            // joystick button up
            else if( msg.isButtonUp() )
            {
                <<< "button", msg.which, "up" >>>;
                0 => gt.isButtonDown;
            }
        }

        spork ~ sendGametrakOverOSC();
    }
}

fun void sendGametrakOverOSC() {
    // NOTE
    // This implementation hardcodes the currentTime and lastTime variable of the gameTrak as 0, with an increment of 0.001

    // id, deserialize(gametrak data object)
    // type string: i f f f f f f f f f f f f f f i
    xmit.start( "/gametrak" );

    // gametrak ID
    // int
    gametrakID => xmit.add; 

    // timestamps (dummy for now till we poke Ge and find out datatype of Time)
    // float, float
    dummmyTimestamp => xmit.add;
    dummmyTimestamp => xmit.add;
    
    // previous axis data
    // 6 x floats
    for ( int i; i < gt.lastAxis.size(); i++) {
        gt.lastAxis[i] => xmit.add;
    }

    // current axis data
    // 6 x floats
    for ( int i; i < gt.axis.size(); i++) {
        gt.axis[i] => xmit.add;
    }

    // button status
    // int
    gt.isButtonDown => xmit.add;

    // send osc object
    xmit.send();

    0.001 +=> dummmyTimestamp;
}
