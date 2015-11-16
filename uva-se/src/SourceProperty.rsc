module SourceProperty

import IO;
import lang::java::m3::Core;

import Rank;

import metrics::CyclomaticComplexity;
import metrics::Duplication;
import metrics::UnitSize;
import metrics::Volume;

public data SourceProperty =
	Volume()
  | Duplication()
  | UnitComplexity()
  | UnitSize();
  

public Rank rank(Volume(), M3 model, bool verbose) {
	if(verbose) println("MEASURING VOLUME...");
	return metrics::Volume::rank(model);
}

public Rank rank(UnitComplexity(), M3 model, bool verbose) {
	if(verbose) println("MEASURING UNIT COMPLEXITY...");
	return metrics::CyclomaticComplexity::rank(model);
}

public Rank rank(Duplication(), M3 model, bool verbose) {
	if(verbose) println("MEASURING DUPLICATION...");
	return metrics::Duplication::rank(model, verbose=verbose);
}

public Rank rank(UnitSize(), M3 model, bool verbose) {
	if(verbose) println("MEASURING UNIT SIZE...");
	return metrics::UnitSize::rank(model);
}