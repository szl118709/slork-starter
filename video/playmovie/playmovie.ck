//----------------------------------------------------------------------------
// name: playmovie.ck
// desc: a simple controller for playmovie.pde (Processing) over OSC
//       for Tess and Andrew and anyone else working with
//       interactive video in Processing + ChucK!
//
// to play: run this with playmovie.pde
//
// author: Ge Wang (https://ccrma.stanford.edu/~ge/)
// date: Winter 2022
//----------------------------------------------------------------------------
 
// destination host name
"localhost" => string hostname;
// destination port number
12000 => int port;

// check command line
if( me.args() ) me.arg(0) => hostname;
if( me.args() > 1 ) me.arg(1) => Std.atoi => port;

// sender object
OscOut xmit;

// aim the transmitter at destination
xmit.dest( hostname, port );

// infinite time loop
while( true )
{
    // start the message...
    xmit.start( "/foo/playmovie" );
    
    // add int argument
    0 => xmit.add;
    // add float argument
    0.2 => xmit.add;
    // add rate
    1.5 => xmit.add;
    
    // send it
    xmit.send();

    // advance time
    0.25::second => now;
}
