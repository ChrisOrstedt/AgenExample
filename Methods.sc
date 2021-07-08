+ TempoClock {

	isBetween { arg numBeats, betweenThis, andThis;
		^((this.beats)%16+1).inclusivelyBetween(betweenThis, andThis+1);
	}


	eights {
		^(this.beats%1).linlin(0, 1, 0, 2).asInteger.even
	}

	everyBar { arg everyThis, offset = 0, beatsInBar = 4;
		^(((this.beats-offset)/beatsInBar)%everyThis).asInteger==(everyThis-1)
	}


	everyBeat { arg everyThis, offset=0;
		^((this.beats-offset)%everyThis).asInteger==(everyThis-1)
	}

	every { arg everyThis, offset=0;
		^(((this.beats*4)-offset)%everyThis).asInteger==(everyThis-1)
	}

	even {
		^this.beats.asInteger.even;
	}

	odd {
		^this.beats.asInteger.odd;
	}

}

+ SimpleNumber {

	isZero {

	^(this.asFloat==0.0)

	}

}

+ Event {

	nextAll { arg notThis;


		this.asArray.do({ arg item, notThis;

			if(item != notThis) {
				item.next;
			};
		})

	}

}

+ Collection {

	nilIdx {
		var array = Array.new;
		this.do({arg item, idx;  if(item==0) {array = array.add(idx)}});
		^array
	}

	notNilIdx {
		var array = Array.new;
		this.do({arg item, idx;  if(item!=0) {array = array.add(idx)}});
		^array
	}

	putatnil {arg putThis;

		this.do({arg item, idx;
			if(item==0) {this.put(idx, putThis[idx])};
		});

	}

	postRows {
		this.do({arg item; item.postln});
	}
}

+ List {

	addOnce {arg addThis;
		if(this.includesEqual(addThis)) {} {this.add(addThis)};
	}
}

+ SynthDef {
	toList {
		SynthDefCollector.setList(this.name);
		^"%% was added to the Collector.".format("\\", this.name);
	}
}

