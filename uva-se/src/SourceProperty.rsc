module SourceProperty

import IO;
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

public tuple[Rank,Metric] rank(Volume(), M3 model) {
	println("Measuring volume...");
	result = metrics::Volume::rank(model);
	println(toString(result)+"\n");
	return result;
}

public tuple[Rank,Metric] rank(UnitComplexity(), M3 model) {
	println("Measuring unit complexity...");
	result = metrics::CyclomaticComplexity::rank(model);
	println(toString(result)+"\n");
	return result;
}

public tuple[Rank,Metric] rank(UnitSize(), M3 model) {
	println("Measuring unit size...");
	result = metrics::UnitSize::rank(model);
	println(toString(result)+"\n");
	return result;
}

public tuple[Rank,Metric] rank(Duplication(), M3 model) {
	println("Measuring duplication...");
	result = metrics::Duplication::rank(model);
	println(toString(result)+"\n");
	return result;
}

public str toString(tuple[Rank,Metric] result)
	= "<toString(result[0])>\n<toString(result[1])>";