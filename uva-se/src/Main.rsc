module Main

import List;
import Set;
import lang::java::m3::Core;

import Metric;
import Rank;
import QualityCharacteristic;
import SourceProperty;


public tuple[map[SourceProperty, tuple[Rank,Metric]], map[QualityCharacteristic, Rank]] rank(
	set[QualityCharacteristic] qualityCharacteristics,
	M3 model
) {
	set[SourceProperty] relevantProperties = union({
		relevantSourceProperties(characteristic) | characteristic <- qualityCharacteristics
	});
	
	map[SourceProperty, tuple[Rank,Metric]] properties = rank(relevantProperties, model);
	map[SourceProperty, Rank] propertyRanks = (
		property : properties[property][0] | property <- properties
	);

	map[QualityCharacteristic, Rank] characteristicRanks = (
		characteristic : rank(characteristic, propertyRanks) | characteristic <- qualityCharacteristics
	);
	
	return <properties, characteristicRanks>;
}

public map[SourceProperty, tuple[Rank,Metric]] rank(set[SourceProperty] properties, M3 model)
	= (property : rank(property, model) | property <- properties);
	
public str toString(map[SourceProperty, tuple[Rank,Metric]] result) {
	lines = sort([ "<toString(property)>\n<toString(result[property])>" | property <- result ]);
	return intercalate("\n\n", lines);
}

public str toString(map[QualityCharacteristic, Rank] result) {
	lines = sort([ "<toString(characteristic)>\n<toString(result[characteristic])>" | characteristic <- result ]);
	return intercalate("\n\n", lines);
}

public str toString(tuple[map[SourceProperty, tuple[Rank,Metric]], map[QualityCharacteristic, Rank]] result) =
	"<toString(result[0])>\n\n\n<toString(result[1])>";