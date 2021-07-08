//////////// AGEN EXAMPLES ////////////

/*
This is a brief rundown of a set of classes and methods I've devised
to accomodate the kind of composition I'm currently interested in.
I wanted "quick" and "simple" sharing of control data in the current,
past and future time domain to get a "conditional" and immediate workflow.

I'm not going to get too technical in this summary but basically the idea
is to feed values into an Array, shift the contents of that array at some arbtitrary
rate (the following examples will shift the arrays every 1/16 at a tempo of 140bpm)
and then have some SynthDef use the value at the MIDDLE of that array as data for an argument.
The use of doing all this is to make the "future" and "past" available in the present.
Like: "if the kick will have some reverb on it two beats from now, the snare will be panned left
right now". Or whatever.

I've tried to streamline the process of doing this so it might seem a bit
esoteric at first. feel free to look over the classes and methods and change things around.
A lot could be improved but I have a habbit of half-assing things when I'm doing
things for myself.
*/

// Ok, first things first. Instantiate the TempoClock and the two SynthDefs down below.
// A Single cmd+enter will do.
// The post window will only print "\bass was added to the Collector."
// but they're both there, presumably.


(
	t = TempoClock.new(120/60).permanent_(true);
	t.tempo_(140/60);
	t.permanent_(true);


SynthDef(\kick, {
	|ampArg = 0, baseFreq = 50|
	var sig, ampEnv, pitchEnv;

		pitchEnv = EnvGen.ar(Env.new(
			[50, baseFreq*100, baseFreq*3.5, baseFreq*1.6, baseFreq],
			[0.003, 0.001, 0.03, 0.1]
			)
		);

		ampEnv = EnvGen.ar(Env.new(
			[0, 1, 0.4, 0.1, 0],
			[0.01, 0.001, 0.4, 0.15],
			[5, -5, -5]),
			doneAction:2
		);

		sig = SinOsc.ar(pitchEnv, mul:ampEnv)!2;
		sig = sig*ampEnv;
		sig = sig*ampArg;
		Out.ar(0, sig);
	}).add.toList;


SynthDef(\bass, {
	|ampArg = 0, oscFreq = 100, filterFreq = 1000, pan = 0|
	var sig, ampEnv, filterEnv;

		ampEnv = EnvGen.ar(Env.new(
			[0, 1, 0.4, 0.1, 0],
			[0.01, 0.1, 0.4, 0.2],
			[5, -5, -5]),
			doneAction:2
		);

			filterEnv = EnvGen.ar(Env.new(
			[1, 4, 0.2],
			[0.01, 0.2],
			[5, -5])
		);


		sig = Saw.ar(oscFreq);
		sig = Pan2.ar(sig, pan);
		sig = LPF.ar(sig, filterFreq*filterEnv);
		sig = sig*ampEnv;
		sig = sig*ampArg;
		Out.ar(0, sig);
	}).add.toList
)


// Notice the method .toList after .add on both of the SynthDefs.
// .toList adds the the names of the arguments of that specific SynthDef
// to a list and pairs them with the name of that SynthDef.



// This thing does a bunch of stuff. Creates the Arrays, assigns keys to the arrays, etc.
// The Class definitions will explain this better. Instantiate it.
a=AgenTree.new;

// If you run this the post window will show you what we're working with.
// At the top layer you have SynthDef names paired with another Event of
// the argument names of that SynthDef. The argument names are in turn paired with
// an objects called Agen2. Agen2 is where the Arrays are doing their thing.
a.tree;

// This function is where the composer manipulates the arrays, i.e., composes.
// It is also responsible for shifting the arrays with the .nextAll call on the AgenTree.
// Instantiate it.
(
~main = {

	// This method call shifts the Arrays.
	a.nextAll;

	// So, there is a few special things going on here.
	// The condition of this if-statement (.every(4)) is a special method of TempoClock.
	// It returns True every "user specified" 1/16ths of the clock it's associated with.
	// The next line of code specifies what will happen to what array when .every returns true.
	// In this specific statement we're putting a 1 in the Array accociated with the
	// amplitude of SynthDef \kick.
	// The first argument of .put is specifying where in that array to put the 1.
	// I've set it up so that 0 is the middle of the array i.e. the "present".
	// Positive integers are the "future", negative, the "past".
	// In it's current configuration, the Array within Agen2 contains 17 elements.
	// This means we have 8 elements of "past" one element of "present" and 8 elements of "future".
	// Remember, the SynthDefs only care about what's in the MIDDLE of the Array.
	if(t.every(4)) {
		a.at(\kick).at(\ampArg).put(8, 1.0)
	};

	// This is just so that we can see what's going on once we run everything.
	a.at(\kick).at(\ampArg).array.postln;
}
)

// This Routine is what ties it all together.
(
r{
	// The AgenPlayers pulls the values at the middle of their corresponding Agen2's,
	// makes sure everything is on time and instantiates Synth objects with those values.
	// AgenPlayer needs four arguments:
	// the name of a SynthDef, an instance of AgenTree, an instance of TempoClock and the server.
	AgenPlayer(\bass, a, t, s);
	AgenPlayer(\kick, a, t, s);

	// This one function call is what keeps the engine churning. The array is shifted and whatever
	// conditionals we've put in there pops of. Then it waits a fourth of one beat, the AgenPlayers
	// pops off and ~main.value is called again.
	~main.value;
	0.25.wait;
}.loop.play(t, quant:[1]);
)











