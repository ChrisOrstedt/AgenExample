Agen2 {
	var <>array, <>lastIndex, defaultValue;

	*new { arg defaultValue;
		^super.new.makeArray_(defaultValue)
	}

	makeArray_ {arg argDefaultValue;
		array=0!17;
		defaultValue = argDefaultValue;
		lastIndex = array.size-1;

	}

	insert { arg index, list;

		list.size.do{
			array.removeAt(index);
		};
		array=array.insert(index, list);
		array=array.flat;
		^array
	}

	idx {arg thisIdx;

		^array[thisIdx+(array.middleIndex)];

	}

	swap {arg swapThis, andThis;

		array.swap(swapThis+(array.middleIndex), andThis+(array.middleIndex));
		^array

	}

	put { arg index, item;
		array.put(index+(array.middleIndex), item);
		^array
	}

	next {
		array=array.shift(-1, defaultValue);
		^array
	}
}

AgenEvent {
	var <>agenList, <>agenEvent;

	*new { arg synthName;
		^super.new.makeAgenList_(synthName)
	}


	makeAgenList_{arg synthName;
		var controls, name, val, agenList = List.new;

		controls=SynthDescLib.global.synthDescs.at(synthName).controls;

		controls.do{|control|
			name = control.name.asSymbol;
			val = control.defaultValue;
			agenList.add(name);
			agenList.add(Agen2(val));
		};
		agenEvent = agenList.asEvent;
		^agenEvent;
	}

}

AgenTree {
	var <>synthList, <>tree, agenEvent;
	*new {
		^super.new.makeTree
	}
	makeTree{
		var holdList = List.new;

		SynthDefCollector.getList.do({arg synthName;
			holdList.add(synthName);
			holdList.add(AgenEvent(synthName));
		});
	tree = holdList.asEvent;
	}

	at {arg atThis;
		^this.tree.at(atThis);
	}

	nextAll {
		this.tree.asArray.do({
			arg item; item.asArray.do({
				arg item; item.next;
			})
		})
	}
}


SynthDefCollector {
	classvar <>synthList;

	*initClass{
		synthList = List.new
	}

	*getList {
		^synthList
	}

	*setList {arg addThis;
		synthList.addOnce(addThis);
	}

}


AgenPlayer {

	*new {arg synthDefName, agenTree, clock, server;
		^super.new.makeSynthAtZero(synthDefName, agenTree, clock, server)
	}

	makeSynthAtZero {arg synthDefName, agenTree, clock, server;
		var synth;

		server.makeBundle(0.25, {synth=Synth.new(synthDefName,
			agenTree.at(synthDefName).collect({
				arg item; item.idx(0)
			}).asPairs
			)
		})
	}
}