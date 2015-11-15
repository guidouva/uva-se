module metrics::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import IO;
import String;
import List;
import Set;
import Map;

import util::Math;
import util::Benchmark;

import Rank;
import metrics::helpers::Model;
import metrics::helpers::Code;

public Rank rank(M3 model, bool verbose = true) {
	<clonedLines, linesOfCode> = findClones(6, model, verbose = verbose);
	return rank(clonedLines, linesOfCode);
}

public Rank rank(int clonedLines, int totalLines) {
	duplicationPercentage = clonedLines * 1.0 / totalLines;
	
	if (duplicationPercentage < .03)
		return Excellent();
	if (duplicationPercentage < .05)
		return Good();
	if (duplicationPercentage < .1)
		return Neutral();
	if (duplicationPercentage < .2)
		return Bad();
	return Dismal();
}

public tuple[int,int] findClones(
	int threshold, M3 model, bool verbose = true
) {
	\start = realTime()*1.0;

	if(verbose) println("[1/3] loading lines of code into memory...");

	allText = (""
		| it + readFile(location)+"\n"
		| location <- classes(model)
	);
	
	if(verbose) println("[2/3] removing comments...");
	
	allLines = [ line | line <- split("\n", removeComments(allText))
					  , !isEmpty(trim(line)) ];
			
	allTrimmedLines = [ trim(line) | line <- allLines ];

	if(verbose) {
		println("[3/3] searching for clones");
		println("indexing lines...");
	}

	fullIndex = indexLines(allTrimmedLines);
	map[str,list[int]] index = domainR(fullIndex, { line | line <- fullIndex, size(fullIndex[line]) > 1 });
	
	totalSize = size(allTrimmedLines);
	
	if(verbose) println("totalSize: <totalSize>");

	clonedLines = {};
	clones = ();
	
	for(line <- index) {
	
		lineNumbers = index[line];
		numLines = size(lineNumbers);
		
		if(verbose) print("[<numLines>] <line>");
		
		for(i <- [0..numLines-1]) {
			
			if(verbose) print(".");

			if(totalSize - lineNumbers[i] < threshold)
				continue;

			
			for(j <- [i+1..numLines]) {
				
				if(totalSize - lineNumbers[j] < threshold
					|| abs(lineNumbers[i] - lineNumbers[j]) < threshold)
					continue;
					
				if(isClone(threshold, allTrimmedLines, lineNumbers[i], lineNumbers[j])) {
					clonedLines += { lineNumbers[i] + k, lineNumbers[j] + k | k <- [0..threshold] };

					if(lineNumbers[i] notin clones) clones[lineNumbers[i]] = {};
					clones[lineNumbers[i]] += lineNumbers[j];

					if(lineNumbers[j] notin clones) clones[lineNumbers[j]] = {};
					clones[lineNumbers[j]] += lineNumbers[i];
				}
			}
		}
		
		if(verbose) println("");
		
	}
	
	if(verbose) {
		println("");
		printClones(threshold, allLines, clones);
	}
	
	end = realTime()*1.0;
	seconds = (end - \start) / 1000;
	
	if(verbose) println("runtime: <seconds>s");
	
	return <size(clonedLines), totalSize>;
}

private void printClones(int threshold, list[str] lines, map[int,set[int]] clones) {
	// sort in order of duplicate occurrences
	blocks = sort([ line | line <- clones ], bool(int a, int b){
		return size(clones[a]) > size(clones[b]);
	});
	
	totalClonesFound = 0;

	printedBlocks = {};
	for(block <- blocks,
		clones[block] - printedBlocks == clones[block]) {

		println("FOUND <size(clones[block])+1> TIMES:");
		for(line <- [block..block+threshold]) println(lines[line]);

		totalClonesFound += size(clones[block])+1;
		printedBlocks += block;
		println("");

	}
	
	println("FOUND <totalClonesFound> CLONES IN TOTAL");
}

private map[str,list[int]] indexLines(list[str] lines) {
	map[str,list[int]] index = ();

	for(i <- [0..size(lines)]) {
		line = lines[i];
		if(line notin index) {
			index[line] = [i];
		} else {
			index[line] += i;
		}
	}	
	
	return index;
}

private bool isClone(int threshold, list[str] lines, int aOffset, int bOffset) {
	cloneSize = 0;	

	while(cloneSize < threshold
			&& lines[aOffset+cloneSize] == lines[bOffset+cloneSize]) {
		cloneSize += 1;
	}
	
	return cloneSize == threshold;
}

private M3 modelTest = createM3FromEclipseProject(|project://duplication-test|);

test bool testFindClones() {
	<clonedLines, _> = findClones(6, modelTest, verbose=false);
	return clonedLines == 46;
}

test bool testRank() = rank(modelTest, verbose=false) == Dismal();