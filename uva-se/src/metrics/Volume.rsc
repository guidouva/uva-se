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
		content = removeComments(content);
		count += (0 | it + 1 | line <- split("\n", content), trim(line) != "");
	}
	
	return count;
}

public int compilationUnitVolume(str project) {
	count = 0;
	
	model = createM3FromEclipseProject(|project://<project>|);
	
	{ l | l <- domain(model@containment), l.scheme == "java+compilationUnit" };
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