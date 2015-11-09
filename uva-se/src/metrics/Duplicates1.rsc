module metrics::Duplicates1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import IO;
import String;
import List;
import Set;

import metrics::ModelHelpers;
import metrics::CodeHelpers;

int numCloneLines(M3 model) {
	println("[1/4] loading lines of code into memory...");

	allText = (""
		| it + readFile(location)+"\n"
		| location <- compilationUnits(model)
	);
	
	println("[2/4] removing comments...");
	
	allLines = [ trim(line) | line <- split("\n", removeComments(allText))
						    , !isEmpty(trim(line)) ];

	println("[3/4] indexing lines of code...");
	lineIndex = indexLines(allLines);
	
	println("[4/4] counting total lines of clones");
	return numCloneLines(6, allLines, lineIndex);
}

map[str,list[int]] indexLines(list[str] lines) {
	map[str,list[int]] index = ();

	for(i <- [0..size(lines)]) {
		line = lines[i];
		if(line notin index) {
			index[line] = [i];
		} else {
			index[line] = index[line] + i;
		}
	}	
	
	return index;
}

public int numCloneLines(int threshold, list[str] lines, map[str,list[int]] index) {
	
	totalSize = size(lines);
	cloneLines = {};
	
	for(line <- index) {
	
		lineNumbers = index[line];
		numLines = size(lineNumbers);
		
		for(i <- [0..numLines-1], j <- [i+1..numLines]) {
			<realI, realJ, cloneSize> =
				clone(totalSize, lines, lineNumbers[i], lineNumbers[j]);
			
			if(cloneSize >= threshold) {
				sz = size(cloneLines);
				cloneLines = cloneLines + { realI + k, realJ + k | k <- [0..cloneSize] };
				if(size(cloneLines) - sz > 0) {
					c = ("" | it + "[<realJ+k>] " + lines[realJ+k] + "\n" | k <- [0..cloneSize]);
					print(c);
				}
			}
		}
		
	}
	
	return size(cloneLines);
	
}

tuple[int,int,int] clone(int szlines, list[str] lines, int aOffset, int bOffset) {

	realOffset = 0;
	while(aOffset-realOffset >= 1 && bOffset-realOffset >= 1
		&& lines[aOffset-realOffset-1] == lines[bOffset-realOffset-1]
	) {
		realOffset += 1;	
	}
	
	aOffset -= realOffset;
	bOffset -= realOffset;
	
	cloneSize = 0;	
	while(aOffset+cloneSize < szlines && bOffset+cloneSize < szlines &&
		lines[aOffset+cloneSize] == lines[bOffset+cloneSize]) {
		cloneSize += 1;
	}
	
	return <aOffset, bOffset, cloneSize>;
	
}

//test bool testNumClones() =
	//numClones(createM3FromEclipseProject(|project://duplication-test|)) == 10;