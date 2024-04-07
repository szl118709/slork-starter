// # of channels
6 => int CHANNELS;

// array of impulses
Impulse imps[CHANNELS];
// array of filters
LPF fs[CHANNELS];
// array of reverbs
NRev rs[CHANNELS];

// loop to connect them all
for( int i; i < CHANNELS; i++ )
{
    // connect
    imps[i] => fs[i] => rs[i] => dac.chan(i);
    // set params
    .1 => rs[i].mix;
}

// the current channel
0 => int n;

// time loop
while( true )
{
    // cutoff frequency
    Math.random2f(5000,5500) => fs[n].freq;

    // fire an impulse!
    1 => imps[n].next;
    
    n++;
    6 %=> n;
   
    // let time advance
    60::ms => now;
}
