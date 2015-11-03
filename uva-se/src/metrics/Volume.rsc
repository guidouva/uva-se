module metrics::Volume

import IO;
import Relation;
import String;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

public int LOC(M3 model) {
	return (0 | it + i | i <- { LOC(l) | l <- compilationUnits(model) });
}

private set[loc] compilationUnits(M3 model) =
	{ l | l <- domain(model@containment), l.scheme == "java+compilationUnit" };

private int LOC(loc file) {
	content = readFile(file);
	content = removeComments(content);
	return (0 | it + 1 | line <- split("\n", content), trim(line) != "");
}

private str removeComments(str content) =
	removeMultiLineComment(removeSingleLineComment(content));

private str removeSingleLineComment(str content) =
	visit(content) {
		case /[\/]{2}.*/ => ""
	};

private str removeMultiLineComment(str content) =
	visit(content) {
		case /[\/][\*].*?[\*][\/]/s => "\n"
	};

test bool testLOC() =
	LOC(createM3FromEclipseProject(|project://volume-test|)) == 17;