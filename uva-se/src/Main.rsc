module Main

import Set;
import lang::java::m3::Core;

import Rank;
import QualityCharacteristic;
import SourceProperty;


public map[QualityCharacteristic, Rank] rank(
	set[QualityCharacteristic] qualityCharacteristics,
	M3 model,
	bool verbose = true
) {
	set[SourceProperty] relevantProperties = union({
		relevantSourceProperties(characteristic) | characteristic <- qualityCharacteristics
	});
	
	map[SourceProperty, Rank] propertyRanks = (
		property : rank(property, model, verbose) | property <- relevantProperties
	);

	return (characteristic : rank(characteristic, propertyRanks) | characteristic <- qualityCharacteristics);
}