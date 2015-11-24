module AstCloneDetector

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Node;
import IO;
import List;
import Set;

import metrics::Duplication;

public void findClones(loc project) {
	set[Declaration] asts = createAstsFromEclipseProject(project, false);
	
	list[list[str]] tokens = [];
	
	for (ast <- asts) {
		tokens += [[token | <token, _> <- tokenize(ast)]];
		println({token | <token, l> <- tokenize(ast), l == |file://NOTHING|});
	}
	
	blocks = splitInBlocksOf(tokens, 60);
	set[list[tuple[int, int]]] cloneBlocks = clonedBlocks(blocks, 60);
	set[tuple[int, int]] cloneTokens = clonedLines(blocks, 60);
	
	for (<fId, tokenNumber> <- sort([c | c <- cloneTokens])) {
		;//println(tokens[fId][tokenNumber]);
	}
	
	println(size(cloneTokens));
}

public node fixSrcs(node ast) {
	loc lastSrc = ast@src;

	return top-down visit(ast) {
		case v:variables(_, _): {
			v@src ? v[0]@src;
		}
		case e:\infix(_, operator, _): {
			e@src ? lastSrc;
		}
		case e:\postfix(_, operator): {
			e@src ? lastSrc;
		}
		case e:\prefix(operator, _): {
			e@src ? lastSrc;
		}
		case remainder: {
			lastSrc = remainder@src;
		}
	};
}

public list[tuple[str, loc]] tokenize(node ast) {
	//model = createM3FromEclipseProject(|project://volume-test|);
	list[tuple[str, loc]] tokens = [];
	
	top-down visit(ast) {
		case \compilationUnit(_, _): {
			;
		}
		case \compilationUnit(_, _, _): {
			;
		}
		case \package(_): {
			;
		}
		case \package(_, _): {
			;
		}
		case \import(_): {
			;
		}
		case a:assignment(lhs, op, rhs): {
			tokens += <op, a@src ? |file://NOTHING|>;
		}
		case Declaration e: {
			if ("modifiers" in getAnnotations(e)) { 
				for (modifier <- e@modifiers) {
					tokens += tokenize(modifier);
				}
			}
			
			tokens += <getName(e), e@src ? |file://NOTHING|>;	
		}
		
		case e:\infix(_, operator, _): {
			tokens += <operator, e@src ? |file://NOTHING|>;
		}
		case e:\postfix(_, operator): {
			tokens += <operator, e@src ? |file://NOTHING|>;
		}
		case e:\prefix(operator, _): {
			tokens += <operator, e@src ? |file://NOTHING|>;
		}
		case Expression e: {
			tokens += <getName(e), e@src ? |file://NOTHING|>;
		}
		
		case Statement e: {
			tokens += <getName(e), e@src ? |file://NOTHING|>;
		}
		
		case Type e: {
			tokens += <"type", e@src ? |file://NOTHING|>;
		}
	};
	
	return tokens;
}

// Splits the sup9plied files in blocks (list of str) of blocksize.
// Returns a map with the location (file + linenumber) of each block
// and the number of lines over all the files. 
private map[list[str], list[tuple[int, int]]] splitInBlocksOf(list[list[str]] tokensList, int blockSize) {
	map[list[str], list[tuple[int, int]]] blocks = ();
	
	for (i <- [0 .. size(tokensList)]) {
		list[str] tokens = tokensList[i];
		
		if (size(tokens) < blockSize) {
			continue;
		}
		
		for (j <- [0 .. size(tokens) - (blockSize - 1)]) {
			list[str] block = tokens[j .. j + blockSize];
			if (block notin blocks) {
				blocks[block] = [<i, j>];
			} else {
				blocks[block] += <i, j>;
			}
		}
	}
	
	return blocks;
}

private set[list[tuple[int, int]]] clonedBlocks(map[list[str], list[tuple[int, int]]] blocks, int blockSize) {
	set[list[tuple[int, int]]] clones = {};
	
	for (list[str] block <- blocks) {
		list[tuple[int, int]] locations = blocks[block];
		
		if (size(locations) > 1) {
			list[int] tokenNumbers = [tokenNumber | <_, tokenNumber> <- locations];
			
			if (size({fId | <fId, _> <- locations}) == 1) {
				if (max(tokenNumbers) - min(tokenNumbers) < blockSize) {
					continue;
				}
			}
				
			clones += ([] | it + t | t <- locations);
		}
	}
	
	return clones;
}

private set[tuple[int, int]] clonedLines(map[list[str], list[tuple[int, int]]] blocks, int blockSize) {
	set[tuple[int, int]] clones = {};
	
	for (clonedBs <- clonedBlocks(blocks, blockSize)) {
		for (block <- clonedBs) {
			<fileId, tokenNumber> = block;
			clones = (clones | it + <fileId, l> | l <- [tokenNumber .. tokenNumber + blockSize]);
		}
	}

	return clones;
}

public loc totalCoverage(list[loc] locs) {
	total = locs[0];
	last = locs[size(locs)-1];
	total.end.line = last.end.line;
	total.end.column = last.end.column;
	return total;
}

public list[tuple[str,loc]] fixLocationBoundaries(list[tuple[str,loc]] tokens) {
	newtokens = [];
	for(i <- [0..size(tokens)-1]) {
		newtokens[i] = <tokens[i][0], tokens[i][1]>;	
		newtokens[i][1].end.line = newtokens[i+1][1].begin.line;
		newtokens[i][1].end.column = newtokens[i+1][1].begin.column;
	}
	return newtokens;
}