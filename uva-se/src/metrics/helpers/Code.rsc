module metrics::helpers::Code

import IO;
import String;

public int LOC(loc \loc) = LOC(readFile(\loc));

public int LOC(str src) = 
	(0 | it + 1 | line <- split("\n", removeComments(src)), trim(line) != "");

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