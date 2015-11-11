module metrics::helpers::Code

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