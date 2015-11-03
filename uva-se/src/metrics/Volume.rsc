module metrics::Volume

import IO;
import Relation;
import String;
import Set;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import metrics::ModelHelpers;

public int LOC(M3 model) =
	(0 | it + i | i <- { LOC(l) | l <- compilationUnits(model) });

public int LOC(loc file) {
	content = removeComments(readFile(file));	
	return (0 | it + 1 | line <- split("\n", content), trim(line) != "");
}

private str removeComments(str content) =
	removeMultiLineComment(removeSingleLineComment(content));

private str removeSingleLineComment(str content) =
	visit(content) {
		case /[\/]{2}.*/ => ""
	};

private str removeMultiLineComment(str content) {
	content = visit(content) {
		case /[\/][\*].*?[\*][\/]/ => ""
	};
	return visit(content) {
		case /[\/][\*].*?[\*][\/]/s => "\n"
	};
}

test bool testLOC() =
	LOC(createM3FromEclipseProject(|project://volume-test|)) == 18;