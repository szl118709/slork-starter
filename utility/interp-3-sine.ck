//-----------------------------------------------------------------------------
// name: interp-3-sine.ck
// desc: using vec3 as a slewing interpolator to control sine freq
//       note: this also uses an overloaded .interp(dur) that takes a
//       duration as a time step
//
// based on example code:
// https://chuck.stanford.edu/doc/examples/vector/interpolate.ck
//-----------------------------------------------------------------------------

// connect
SinOsc foo => dac;

// the interpolator
vec3 i;
// the interpolation rate
10::ms => dur irate;
// set initial .value, .goal, .slew
i.set( 440, 440, .05 * (second/irate) );

// spork interpolate function
spork ~ interpolate( irate );

// main shred sets the goal
while( true )
{
    // set interpolator goal
    i.update( Math.random2f(200,1000) );
    // every so often
    500::ms => now;
}

// function to drive interpolator(s) concurrently
fun void interpolate( dur delta )
{
    while( true )
    {
        // interpolate
        i.interp( delta );
        // use current value to update parameter
        i.value => foo.freq;
        // advance time by rate
        delta => now;
    }
}
