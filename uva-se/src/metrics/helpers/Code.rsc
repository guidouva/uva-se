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
		case /<before:.*><comment:[\/]{2}.*>/ => before + ( endsInString(before) ? comment : "" )
	};

private str removeMultiLineComment(str content) {
	content = visit(content) {
		case /<before:.*><comment:[\/][\*].*?[\*][\/]>/ => before + ( endsInString(before) ? comment : "" )
	};
	return visit(content) {
		case /<before:.*><comment:[\/][\*].*?[\*][\/]>/s => before + ( endsInString(before) ? comment : "\n" )
	};
}

private bool endsInString(str s) {
	bool inString = false;
	bool escaping = false;

	for(i <- [0..size(s)]) {
		str c = stringChar(charAt(s, i));
		if(!inString) {
			inString = c == "\"";
		} else {
			if(escaping) escaping = false;
			else {
				if(c == "\\") escaping = true;
				else inString = c == "\"";
			}
		}
	}
	
	return inString;
}