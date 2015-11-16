module Core

import List;
import lang::java::m3::Core;

import Rank;
import QualityCharacteristic;
import SourceProperty;

import metrics::CyclomaticComplexity;
import metrics::Duplication;
import metrics::UnitSize;
import metrics::Volume;

public map[QualityCharacteristic, Rank] rank(
	set[QualityCharacteristic] qualityCharacteristics,
	M3 model,
	loc project = |unknown:///|,
	bool verbose = true
) {
	map[SourceProperty, Rank] propertyRanks = ();
	
	set[SourceProperty] relevantProperties = union({
		relevantSourceProperties(characteristic) | characteristic <- qualityCharacteristics
	});

	if(Volume() in relevantProperties) 
		propertyRanks[Volume()] = metrics::Volume::rank(model);
		
	if(UnitComplexity() in relevantProperties) {
	   	if(project == |unknown:///|)
			propertyRanks[UnitComplexity()] = metrics::CyclomaticComplexity::rank(model);
		else
			propertyRanks[UnitComplexity()] = metrics::CyclomaticComplexity::rank(project);
	}
	
	if(Duplication() in relevantProperties)
		propertyRanks[Duplication()] = metrics::Duplication::rank(model, verbose=verbose);
	
	if(UnitSize() in relevantProperties) {
	   	if(project == |unknown:///|)
			propertyRanks[UnitSize()] = metrics::UnitSize::rank(model);
		else
			propertyRanks[UnitSize()] = metrics::UnitSize::rank(project);
	}
	
	return toMap([ <characteristic, rank(characteristic, propertyRanks)> | characteristic <- qualityCharacteristics ]);
}