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
	
	set[tuple[int, int]] clones = clonedLines(splitInBlocksOf(tokens, 60), 60);
	println(size(clones));
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