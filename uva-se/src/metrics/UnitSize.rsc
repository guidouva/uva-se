module metrics::UnitSize

import Set;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import metrics::Volume;

import metrics::helpers::Model;

public real unitSize(M3 model) {
	units = compilationUnits(model);
	return (0 | it + LOC(unit) | unit <- units) / (size(units) * 1.0);
}

test bool unitSizeTest() =
	unitSize(createM3FromEclipseProject(|project://volume-test|)) == 9.;