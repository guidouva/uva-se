module SourceProperty

import IO;
import lang::java::m3::Core;

import Rank;

import metrics::helpers::Rank;

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
	if (!verbose) 
		return metrics::Volume::rank(model);
		
	println("MEASURING VOLUME...");
	
	int linesOfCode = metrics::Volume::LOC(model);
	println("Lines of code: <linesOfCode>");
	
	Rank r = metrics::Volume::rank(linesOfCode);
	println("Rank: <r>");
	
	return r;
}

public Rank rank(UnitComplexity(), M3 model, bool verbose) {
	if(!verbose) 
		return metrics::CyclomaticComplexity::rank(model);
	
	println("MEASURING UNIT COMPLEXITY...");
	
	list[tuple[int, int]] complexity = metrics::CyclomaticComplexity::cyclomaticComplexityPerMethod(model);
	tuple[real, real, real] profile = metrics::helpers::Rank::riskProfile(10, 20, 50, complexity);
	
	println("Risk profile: moderate: <profile[0] * 100>%, high: <profile[1] * 100>%, very high: <profile[2] * 100>%");
	
	Rank r = metrics::helpers::Rank::rankProfile(profile);
	println("Rank: <r>");
	
	return r;
}

public Rank rank(Duplication(), M3 model, bool verbose) {
	if (!verbose) 
		return metrics::Duplication::rank(model, verbose=verbose);
		
	println("MEASURING DUPLICATION...");
	<clonedLines, linesOfCode> = findClones(6, model, verbose = false);
	
	println("Number of cloned lines: <clonedLines>, number of lines of code: <linesOfCode>");
	
	Rank r = metrics::Duplication::rank(clonedLines, linesOfCode);
	println("Rank: <r>");
	
	return r;
}

public Rank rank(UnitSize(), M3 model, bool verbose) {
	if (!verbose) 
		return metrics::UnitSize::rank(model);
		
	println("MEASURING UNIT SIZE...");
	list[tuple[int,int]] sizes = sizePerMethod(model);
	tuple[real, real, real] profile = metrics::helpers::Rank::riskProfile(20, 50, 100, sizes);
	
	println("Risk profile: moderate: <profile[0] * 100>%, high: <profile[1] * 100>%, very high: <profile[2] * 100>%");
	
	Rank r = metrics::helpers::Rank::rankProfile(profile);
	println("Rank: <r>");
	
	return r;
}