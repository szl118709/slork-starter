//-----------------------------------------------------------------------------
// name: interp-2-vec3.ck
// desc: using vec3 as a slewing interpolator
//       this is quite useful to making a percentage progress
//       towards a goal, in an amount proportional to the slew
//       and some delta time
//
// based on example code:
// https://chuck.stanford.edu/doc/examples/vector/interpolate.ck
//-----------------------------------------------------------------------------

// the interpolator
vec3 interp;
// set initial .value, .goal, .slew
interp.set( 0, 0, .001 );

// spork interpolate function
spork ~ interpolate();

// set target value
interp.update(1); // same as: 1 => interp.goal;
// let time pass
3000::ms => now;
// set another target value
interp.update(5); // same as: 5 => interp.goal;
// let time pass
3000::ms => now;
// set another target value
interp.update(0); // same as: 0 => interp.goal;
// let time pass
1::hour => now;

// function to drive interpolator(s) concurrently
fun void interpolate()
{
    while( true )
    {
        // interpolate
        interp.interp();
        // time step
        10::samp => now;
        // print
        <<< "current value:", interp.value >>>;
    }
}
