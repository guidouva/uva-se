module SourceProperty

import lang::java::m3::Core;

import Metric;
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
  
 
public str toString(Volume()) = "volume";
public str toString(Duplication()) = "duplication";
public str toString(UnitComplexity()) = "unit complexity";
public str toString(UnitSize()) = "unit size";

public tuple[Rank,Metric] rank(Volume(), M3 model) = metrics::Volume::rank(model);
public tuple[Rank,Metric] rank(UnitComplexity(), M3 model) = metrics::CyclomaticComplexity::rank(model);
public tuple[Rank,Metric] rank(UnitSize(), M3 model) = metrics::UnitSize::rank(model);

public str toString(tuple[Rank,Metric] result)
	= "<toString(result[0])>\n<toString(result[1])>";

  
/*
public Rank rank(Duplication(), M3 model) {
	if (!verbose) 
		return metrics::Duplication::rank(model, verbose=true);
		
	println("MEASURING DUPLICATION...");
	<clonedLines, linesOfCode> = findClones(6, model, verbose = false);
	
	println("Number of cloned lines: <clonedLines>, number of lines of code: <linesOfCode>");
	
	Rank r = metrics::Duplication::rank(clonedLines, linesOfCode);
	println("Rank: <r>");
	
	return r;
}
*/