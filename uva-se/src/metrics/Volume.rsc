module metrics::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import demo::common::Crawl;
import IO;
import String;

public int volume(str project) {
	count = 0;
	
	for (file <- getJavaFiles(project)) {
		content = readFile(file);
		content = filterComments(content);
	
		for (line <- split("\n", content)) {
			if (trim(line) != "") {
				count += 1;
			}
		}
	}
	
	return count;
}

private list[loc] getJavaFiles(str project) {
	return crawl(|project://<project>/src|, ".java");
}

private str filterComments(str content) {
	return filterMultiLineComment(filterSingleLineComment(content));
}

private str filterSingleLineComment(str content) {
	return visit(content) {
		case /[\/]{2}.*/ => ""
	};
}

private str filterMultiLineComment(str content) {
	return visit(content) {
		case /[\/][\*].*?[\*][\/]/s => "\n"
	};
}