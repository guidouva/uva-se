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

import metrics::helpers::Model;
import metrics::helpers::Code;

alias line_t = str;

int numClonedLines(M3 model, bool verbose = true) {

	\start = realTime()*1.0;

	if(verbose) println("[1/4] loading lines of code into memory...");

	allText = (""
		| it + readFile(location)+"\n"
		| location <- classes(model)
	);
	
	if(verbose) println("[2/4] removing comments...");
	
	allLines = [ line | line <- split("\n", removeComments(allText))
					  , !isEmpty(trim(line)) ];
			
	allTrimmedLines = [ trim(line) | line <- allLines ];

	if(verbose) println("[3/4] indexing lines of code...");

	fullLineIndex = indexLines(allTrimmedLines);
	lineIndex = domainR(fullLineIndex, { line | line <- fullLineIndex, size(fullLineIndex[line]) > 1 });	

	if(verbose) println("[4/4] searching for clones");
	
	<clonedLines,clones> = findClones(6, allTrimmedLines, lineIndex, verbose = verbose);

	if(verbose) printClones(6, allLines, allTrimmedLines, clones);
	
	end = realTime()*1.0;
	seconds = (end - \start) / 1000;
	
	if(verbose) println("runtime: <seconds>s");
	
	return size(clonedLines);
}

void printClones(int threshold, list[line_t] lines, list[line_t] trimmedLines, map[int,set[int]] clones) {
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

map[line_t,list[int]] indexLines(list[line_t] lines) {
	map[line_t,list[int]] index = ();

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

public tuple[set[int], map[int,set[int]]] findClones(
	int threshold, list[line_t] lines, map[line_t,list[int]] index,
    bool verbose = true
) {
	
	totalSize = size(lines);
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
					
				if(isClone(threshold, lines, lineNumbers[i], lineNumbers[j])) {
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
	
	if(verbose) println("");
	
	return <clonedLines,clones>;
	
}

bool isClone(int threshold, list[line_t] lines, int aOffset, int bOffset) {

	cloneSize = 0;	

	while(cloneSize < threshold
			&& lines[aOffset+cloneSize] == lines[bOffset+cloneSize]) {
		cloneSize += 1;
	}
	
	return cloneSize == threshold;
	
}

test bool testNumCloneLines() =
	numClonedLines(createM3FromEclipseProject(|project://duplication-test|), verbose=false) == 46;