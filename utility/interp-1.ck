//-----------------------------------------------------------------------------
// name: interp-1.ck
// desc: a slewing interpolator
//       this is quite useful to making a percentage progress
//       towards a goal, in an amount proportional to the slew
//       and some delta time
//
// author: Trijeet Mukhopadhyay (trijeetm@gmail.com)
// date: Spring 2022
//-----------------------------------------------------------------------------

// current value for interpolator
0 => float currValue;
// target value
currValue => float targetValue;
// set as desired percentage to move at each step
0.001 => float interpolatorSlew;

// spork the interpolator
spork ~ interpolator();

// set target value
1 => targetValue;
// let time pass
3000::ms => now;
// set another target value
5 => targetValue;
// let time pass
3000::ms => now;
// set another target value
0 => targetValue;
// let time pass
1::hour => now;

// interpolating function
fun void interpolator()
{
    <<< "initial value:", currValue >>>;
    while( true )
    {
        // difference between current and target
        (targetValue - currValue) => float diff;
        // update the current value
        currValue + (diff * interpolatorSlew) => currValue;
        // time step
        10::samp => now;
        // print
        <<< "current value:", currValue >>>;
    }
}
