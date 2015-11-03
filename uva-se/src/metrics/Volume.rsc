module metrics::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import IO;
import String;
import Relation;

public int LOC(M3 model) {
	return (0 | it + i | i <- { LOC(l) | l <- compilationUnits(model) });
}

set[loc] compilationUnits(M3 model) =
	{ l | l <- domain(model@containment), l.scheme == "java+compilationUnit" };


public int LOC(loc file) {
	content = readFile(file);
	content = removeComments(content);
	return (0 | it + 1 | line <- split("\n", content), trim(line) != "");
}

private str removeComments(str content) {
	return removeMultiLineComment(removeSingleLineComment(content));
}

private str removeSingleLineComment(str content) {
	return visit(content) {
		case /[\/]{2}.*/ => ""
	};
}

private str removeMultiLineComment(str content) {
	return visit(content) {
		case /[\/][\*].*?[\*][\/]/s => "\n"
	};
}

test bool testLOC() {
	M3 model = createM3FromEclipseProject(|project://volume-test|);
	return LOC(model) == 17;
}