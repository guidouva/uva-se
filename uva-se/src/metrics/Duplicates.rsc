module metrics::Duplicates

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import IO;
import String;
import List;
import Set;

import util::Math;
import util::Benchmark;

import metrics::ModelHelpers;
import metrics::CodeHelpers;

alias line_t = str;

int numCloneLines(M3 model) {

	\start = realTime()*1.0;

	println("[1/4] loading lines of code into memory...");

	allText = (""
		| it + readFile(location)+"\n"
		| location <- classes(model)
	);
	
	println("[2/4] removing comments...");
	
	allLines = [ trim(line) | line <- split("\n", removeComments(allText))
						    , !isEmpty(trim(line)) ];

	println("[3/4] indexing lines of code...");
	lineIndex = indexLines(allLines);
	
	println("[4/4] counting total lines of clones");
	
	n = numCloneLines(6, allLines, lineIndex);
	
	end = realTime()*1.0;
	seconds = (end - \start) / 1000;
	
	println("runtime: <seconds>s");
	
	return n;
}

int hashCode(str s) {
	int hash = 7;
	for(i <- [0..size(s)]) {
		hash = hash*31 + charAt(s,i);
	}
	return hash;
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

public int numCloneLines(int threshold, list[line_t] lines, map[line_t,list[int]] index) {
	
	totalSize = size(lines);
	cloneLines = {};
	
	for(line <- index) {
	
		lineNumbers = index[line];
		numLines = size(lineNumbers);
		
		print("[<numLines>] <line>");
		
		for(i <- [0..numLines-1]) {
			
			print(".");

			if(totalSize - lineNumbers[i] < threshold)
				continue;

			
			for(j <- [i+1..numLines]) {
				
				if(totalSize - lineNumbers[j] < threshold
					|| abs(lineNumbers[i] - lineNumbers[j]) < threshold)
					continue;
					
				if(isClone(threshold, lines, lineNumbers[i], lineNumbers[j])) {
					cloneLines += { lineNumbers[i] + k, lineNumbers[j] + k | k <- [0..threshold] };
				}
			}
		}
		
		println("");
		
	}
	
	return size(cloneLines);
	
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
	numCloneLines(createM3FromEclipseProject(|project://duplication-test|)) == 46;