module metrics::Duplicates1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import IO;
import String;
import List;
import Set;

import metrics::ModelHelpers;

int numCloneLines(M3 model) {
	println("[1/3] loading lines of code into memory...");
	allLines = ([]
		| it + [ trim(line) | line <- readFileLines(location) ]
		| location <- compilationUnits(model)
	);

	println("[2/3] indexing lines of code...");
	lineIndex = indexLines(allLines);
	
	println("[3/3] counting total lines of clones");
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
		
		println("<line> [<numLines>]");

		for(i <- [0..numLines], j <- [i+1..numLines]) {
			<realI, realJ, cloneSize> =
				clone(totalSize, lines, lineNumbers[i], lineNumbers[j]);
			
			if(cloneSize >= threshold) {
				cloneLines = cloneLines + { realI + k, realJ + k | k <- [0..cloneSize] };
			}
		}
	
	}
	
	return size(cloneLines);
	
}

tuple[int,int,int] clone(int szlines, list[str] lines, int aOffset, int bOffset) {

	realOffset = 0;
	while(lines[aOffset-realOffset-1] == lines[bOffset-realOffset-1]
		&& aOffset-realOffset >= 1 && bOffset-realOffset >= 1
	) {
		realOffset += 1;	
	}
	
	aOffset -= realOffset;
	bOffset -= realOffset;
	
	cloneSize = 0;	
	while(lines[aOffset+cloneSize] == lines[bOffset+cloneSize] &&
		aOffset+cloneSize < szlines && bOffset+cloneSize < szlines) {
		cloneSize += 1;
	}
	
	return <aOffset, bOffset, cloneSize>;
	
}

//test bool testNumClones() =
	//numClones(createM3FromEclipseProject(|project://duplication-test|)) == 10;