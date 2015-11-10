module metrics::CyclicComplexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import IO;
import String;
import Set;

import metrics::CodeHelpers;

public int cyclicComplexity(M3 model) {
	println(size(classes(model)));
	complexity = (0 | it + cyclicComplexity(unit) | unit <- methods(model));
	println(complexity);
	return complexity;
}

public int cyclicComplexity(loc file) {
	int count = 1;
	
	list[str] content = [trim(l) | l <- split("\n", removeComments(readFile(file))), trim(l) != ""];
	
	for (line <- content) {
		if (/\s*for\s*?\(/ := line) {
			count += 1;
		}
		else if (/\s*if\s*?\(/ := line) {
			count += 1;
		}
	}
	
	return count;
}


test bool testCyclicComplexity() =
	cyclicComplexity(createM3FromEclipseProject(|project://duplication-test|)) == 2;