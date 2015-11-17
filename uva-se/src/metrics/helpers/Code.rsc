module metrics::helpers::Code

import IO;
import String;
import List;

public list[int] LOC(list[loc] locations) {
	str allLines = intercalate("\n===== FILE ENDER LINE =====\n", [ readFile(file) | file <- locations ]);
	allLines = removeComments(allLines);
	list[str] fileTexts = split("\n===== FILE ENDER LINE =====\n", allLines);
	return [LOC(text) | text <- fileTexts];
}

public int LOC(loc \loc) = LOC(removeComments(readFile(\loc)));

public int LOC(str src) = 
	(0 | it + 1 | line <- split("\n", src), trim(line) != "");

public str removeComments(str content) =
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