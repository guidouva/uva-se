module AstCloneDetector

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import util::Math;
import Node;
import IO;
import List;
import Set;
import Map;
import Relation;

import metrics::Duplication;

anno loc Type @ src;

alias fid_t = int;
alias tokenindex_t = int;
alias token_t = str;
alias tokenlocation_t = tuple[fid_t,tokenindex_t];
alias block_t = list[token_t];

public void findClones(loc project) {
	int blockSize = 8;
	set[Declaration] asts = createAstsFromEclipseProject(project, false);
	
	list[loc] files = [];
	list[list[tuple[token_t, loc]]] tokensAndLocations = [];
	for (ast <- asts) {
		files += ast@src;
		tokensAndLocations += [tokenize(ast)];
	}
	list[list[token_t]] tokens = [[t | <t, _> <- tokenList] | tokenList <- tokensAndLocations];
	
	map[block_t, list[tokenlocation_t]] blocks = splitInBlocksOf(tokens, blockSize);
	rel[tokenlocation_t, tokenlocation_t] cloneBlocks = clonedBlocks(blocks, blockSize);
	set[tokenlocation_t] cloneTokens = clonedLines(blocks, blockSize);
		
	set[tuple[tokenlocation_t, tokenlocation_t, int]] expandedClonedBlocks = expandClonedBlocks(blocks, blockSize);
	
	for (expandedClonedBlock:<<fId1, tokenNumber1>, <fId2, tokenNumber2>, cloneSize> <- expandedClonedBlocks) {
		clone1Loc1 = tokensAndLocations[fId1][tokenNumber1][1];
		clone1Loc2 = tokensAndLocations[fId1][tokenNumber1 + cloneSize - 1][1];
		clone2Loc1 = tokensAndLocations[fId2][tokenNumber2][1];
		clone2Loc2 = tokensAndLocations[fId2][tokenNumber2 + cloneSize - 1][1];
		
		// TODO, fix location length. Read file manually?
		loc1 = totalCoverage([clone1Loc1, clone1Loc2]);
		loc2 = totalCoverage([clone2Loc1, clone2Loc2]);
		
		println("clone1");
		println("<tokens[fId1][tokenNumber1]> <clone1Loc1>");
		println("<tokens[fId1][tokenNumber1]> <clone1Loc2>");
		
		println("clone2");
		println("<tokens[fId2][tokenNumber2]> <clone2Loc1>");
		println("<tokens[fId2][tokenNumber2]> <clone2Loc2>");
		println();
	}
		
	println("Number of cloned tokens <size(cloneTokens)>.");
}

public set[tuple[tokenlocation_t, tokenlocation_t, int]] expandClonedBlocks(blocks, blockSize) {
	rel[tokenlocation_t,tokenlocation_t] cloneBlocks = clonedBlocks(blocks, blockSize);
	set[tuple[tokenlocation_t, tokenlocation_t, int]] expandedClonedBlocks = {};
	
	// expand blocks downwards
	for (<clone1, clone2> <- cloneBlocks) {
		previousClone1 = <clone1[0], clone1[1] - 1>;
		previousClone2 = <clone2[0], clone2[1] - 1>;
		
		// can skip if clone can be expanded upwards
		if (<previousClone1, previousClone2> in cloneBlocks) {
			continue;
		}
		
		int cloneSize = blockSize;
		tokenlocation_t nextClone1 = <clone1[0], clone1[1] + 1>;
		tokenlocation_t nextClone2 = <clone2[0], clone2[1] + 1>;
		
		while (<nextClone1, nextClone2> in cloneBlocks) {
			cloneSize += 1;
			nextClone1 = <nextClone1[0], nextClone1[1] + 1>;
			nextClone2 = <nextClone2[0], nextClone2[1] + 1>;
		}
		expandedClonedBlocks += <clone1, clone2, cloneSize>;
	}
	
	// filter nested clones
	map[fid_t, map[fid_t, list[tuple[tokenlocation_t, tokenlocation_t, int]]]] cache = ();
	
	for (clonepair:<clone1, clone2, cloneSize> <- expandedClonedBlocks)  {
		cache[clone1[0]] = ();
		cache[clone1[0]][clone2[0]] = [];
	}
	
	for (clonepair:<clone1, clone2, cloneSize> <- expandedClonedBlocks)  {
		cache[clone1[0]][clone2[0]] += clonepair;
	}
	
	set[tuple[tokenlocation_t, tokenlocation_t, int]] result = {};
	
	for (fid_t fid1 <- cache) {
		for (fid_t fid2 <- cache[fid1]) {
			clonepairs = cache[fid1][fid2];
			for (clonepair:<clone1, clone2, cloneSize> <- clonepairs) {
				bool isBiggestBlock = true;
				
				for (otherClonepair:<otherClone1, otherClone2, otherCloneSize> <- cache[fid1][fid2]) {
					if (otherClonepair == clonepair) {
						continue;
					}
					
					if (clone1[1] >= otherClone1[1] &&
						clone1[1] + cloneSize - 1 <= otherClone1[1] + otherCloneSize - 1 &&
						clone2[1] >= otherClone2[1] &&
						clone2[1] + cloneSize - 1 <= otherClone2[1] + otherCloneSize - 1
						) {
							isBiggestBlock = false;
							break;
					}
				}
				if (isBiggestBlock) {
					result += clonepair;
				}
			}		
		}
	}
	
	return result;
}

public list[tuple[token_t, loc]] tokenize(node ast) {
	//model = createM3FromEclipseProject(|project://volume-test|);
	list[tuple[token_t, loc]] tokens = [];
	
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
			tokens += <op, a@src ? |file:///unknown|>;
		}
		case Declaration e: {
			if ("modifiers" in getAnnotations(e)) { 
				for (modifier <- e@modifiers) {
					tokens += tokenize(modifier);
				}
			}
			
			tokens += <getName(e), e@src ? |file:///unknown|>;	
		}
		
		case e:\infix(_, operator, _): {
			tokens += <operator, e@src ? |file:///unknown|>;
		}
		case e:\postfix(_, operator): {
			tokens += <operator, e@src ? |file:///unknown|>;
		}
		case e:\prefix(operator, _): {
			tokens += <operator, e@src ? |file:///unknown|>;
		}
		case Expression e: {
			tokens += <getName(e), e@src ? |file:///unknown|>;
		}
		
		case Statement e: {
			tokens += <getName(e), e@src ? |file:///unknown|>;
		}
		
		case Type e: {
			tokens += <"type", e@src ? |file:///unknown|>;
		}
	};
	
	return tokens;
}

// Splits the sup9plied files in blocks (list of str) of blocksize.
// Returns a map with the location (file + linenumber) of each block
// and the number of lines over all the files. 
private map[block_t, list[tokenlocation_t]] splitInBlocksOf(list[list[token_t]] tokensList, int blockSize) {
	map[block_t, list[tokenlocation_t]] blocks = ();
	
	for (i <- [0 .. size(tokensList)]) {
		list[token_t] tokens = tokensList[i];
		
		if (size(tokens) < blockSize) {
			continue;
		}
				
		for (j <- [0 .. size(tokens) - (blockSize - 1)]) {
		
			block_t block = tokens[j .. j + blockSize];
			if (block notin blocks) {
				blocks[block] = [<i, j>];
			} else {
				blocks[block] += <i, j>;
			}
		}
	}
	return blocks;
}

private rel[tokenlocation_t,tokenlocation_t] clonedBlocks(map[block_t, list[tokenlocation_t]] blocks, int blockSize) {
	rel[tokenlocation_t,tokenlocation_t] clones = {};
	
	for (block <- blocks) {
		locations = blocks[block];
		
		if (size(locations) > 1) {
			tokenNumbers = [tokenNumber | <_, tokenNumber> <- locations];
			
			if (size({fId | <fId, _> <- locations}) == 1) {
				println("here <tokenNumbers>");
				if (max(tokenNumbers) - min(tokenNumbers) < blockSize) {
					continue;
				}
			}
				
			clones += { <l1,l2> | l1 <- locations, l2 <- locations, l1[0] != l2[0] || abs(l1[1] - l2[1]) >= blockSize };
		}
	}
	
	return clones;
}

private set[tokenlocation_t] clonedLines(map[block_t, list[tokenlocation_t]] blocks, int blockSize) {
	set[tokenlocation_t] clones = {};
	
	for (tuple[tokenlocation_t, tokenlocation_t] clonedBs <- clonedBlocks(blocks, blockSize)) {
		<fileId, tokenNumber> = clonedBs[0];
		clones = (clones | it + <fileId, l> | l <- [tokenNumber .. tokenNumber + blockSize]);
	}

	return clones;
}

public loc totalCoverage(list[loc] locs) {
	loc total = locs[0];
	loc last = locs[size(locs)-1];
	total.end.line = last.end.line;
	total.end.column = last.end.column;
	total.length = (0 | it + location.length | location <- locs);
	return total;
}

public list[tuple[token_t,loc]] fixLocationBoundaries(list[tuple[token_t,loc]] tokens) {
	newtokens = [];
	for(i <- [0..size(tokens)-1]) {
		newtokens[i] = <tokens[i][0], tokens[i][1]>;	
		newtokens[i][1].end.line = newtokens[i+1][1].begin.line;
		newtokens[i][1].end.column = newtokens[i+1][1].begin.column;
	}
	return newtokens;
}