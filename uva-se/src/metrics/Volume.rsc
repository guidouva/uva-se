module metrics::Volume

import IO;
import String;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import metrics::helpers::Model;
import metrics::helpers::Code;

public int LOC(M3 model) =
	(0 | it + LOC(l) | l <- compilationUnits(model));

public int LOC(loc file) {
	content = removeComments(readFile(file));	
	return (0 | it + 1 | line <- split("\n", content), trim(line) != "");
}

test bool testLOC() =
	LOC(createM3FromEclipseProject(|project://volume-test|)) == 18;