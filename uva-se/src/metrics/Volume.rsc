module metrics::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import demo::common::Crawl;
import IO;
import String;
import Set;
import Relation;

public int LOC(str project) {
	return (0 | it + LOC(file) | file <- getJavaFiles(project));
}

public int LOC(loc file) {
	content = readFile(file);
	content = removeComments(content);
	return (0 | it + 1 | line <- split("\n", content), trim(line) != "");
}

private list[loc] getJavaFiles(str project) {
	return crawl(|project://<project>/src|, ".java");
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