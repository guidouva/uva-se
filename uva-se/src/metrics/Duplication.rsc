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
	<cloneLines, linesOfCode> = findClones(6, model, verbose = verbose);
	return rank(cloneLines, linesOfCode);
}

public Rank rank(int cloneLines, int totalLines) {
	duplicationPercentage = cloneLines * 1.0 / totalLines;
	
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

	<blocks, linesOfCode> = splitInBlocksOf(classes(model), threshold);
	clones = clonedLines(blocks, threshold);
	
	end = realTime()*1.0;
	seconds = (end - \start) / 1000;
	if (verbose) println("runtime: <seconds>s");
	
	return <size(clones), linesOfCode>; 
}


private set[list[tuple[loc, int]]] clonedBlocks(map[list[str], list[tuple[loc, int]]] blocks, int blockSize) {
	set[list[tuple[loc, int]]] clones = {};
	
	for (list[str] block <- blocks) {
		list[tuple[loc, int]] locations = blocks[block];
		
		if (size(locations) > 1) {
			list[int] lineNumbers = [lNumber | <_, lNumber> <- locations];
			
			if (size({fId | <fId, _> <- locations}) == 1) {
				if (max(lineNumbers) - min(lineNumbers) < blockSize) {
					continue;
				}
			}
				
			clones += ([] | it + t | t <- locations);
		}
	}
	
	return clones;
}

private set[tuple[loc, int]] clonedLines(map[list[str], list[tuple[loc, int]]] blocks, int blockSize) {
	set[tuple[loc, int]] clones = {};
	
	for (clonedBs <- clonedBlocks(blocks, blockSize)) {
		for (block <- clonedBs) {
			<fileId, lineNumber> = block;
			clones = (clones | it + <fileId, l> | l <- [lineNumber .. lineNumber + blockSize]);
		}
	}

	return clones;
}

// Splits the supplied files in blocks (list of str) of blocksize.
// Returns a map with the location (file + linenumber) of each block
// and the number of lines over all the files. 
private tuple[map[list[str], list[tuple[loc, int]]], int] splitInBlocksOf(set[loc] files, int blockSize) {
	int linesOfCode = 0;
	map[list[str], list[tuple[loc, int]]] blocks = ();
	
	for (loc file <- files) {
		str text = readFile(file);
		
		list[str] lines = [trim(line) | line <- split("\n", removeComments(text))
					  			, !isEmpty(trim(line)) ];
		
		linesOfCode += size(lines);
		
		if (size(lines) >= blockSize) {
			for (i <- [0 .. size(lines) - (blockSize - 1)]) {
				list[str] block = lines[i .. i + blockSize];
				if (block notin blocks) {
					blocks[block] = [<file, i>];
				} else {
					blocks[block] += <file, i>;
				}
			}
		}
	}
	
	return <blocks, linesOfCode>;
}

private void printClones(map[list[str], list[tuple[loc, int]]] blocks, int blockSize) {
	for (list[tuple[loc, int]] clones <- clonedBlocks(blocks, blockSize)) {
		println("Found clones <size(clones)> times at: ");
		
		for (clone <- clones) {
			<file, lineNumber> = clone;
			println("file: <file>, linenumber <lineNumber>");
		}
	}
}

private M3 modelTest = createM3FromEclipseProject(|project://duplication-test|);

test bool testFindClones() {
	<numberOfClones, _> = findClones(6, modelTest, verbose=false);
	return numberOfClones == 46;
}

test bool testRank() = rank(modelTest, verbose=false) == Dismal();