module metrics::Duplicates1

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import IO;
import util::Math;
import String;
import List;
import Set;

import metrics::ModelHelpers;

int CLONE_SIZE = 6;

int numClones(M3 model) {
	compUnits = compilationUnits(model);
	allLines = ([] | it + [ trim(line) | line <- readFileLines(l) ] | l <- compUnits);
	return numClones(allLines);
}

public int numClones(list[int] lines) {
	
	totalSize = size(lines);

	if(totalSize < CLONE_SIZE*2) {
		return 0;
	}
	
	cloneLines = {};

	for(i <- [0 .. totalSize - (CLONE_SIZE*2)]) {
	
		if(i % 100 == 0) {
			println("<i> / <totalSize>");
		}
	
		for(j <- [i + CLONE_SIZE .. totalSize - CLONE_SIZE]) {
		
			<realI, realJ, cloneSize> = clone(totalSize, lines, i, j);

			if(cloneSize >= CLONE_SIZE) {
				cloneLines = cloneLines + { realI + k, realJ + k | k <- [0..cloneSize] };
			}

		}

	}
	
	return size(cloneLines);
}

tuple[int,int,int] clone(int szlines, list[int] lines, int aOffset, int bOffset) {

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

test bool testNumClones() =
	numClones(createM3FromEclipseProject(|project://duplication-test|)) == 10;