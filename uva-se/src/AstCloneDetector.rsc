module AstCloneDetector

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Node;
import IO;
import List;
import Set;

import metrics::Duplication;

anno loc Type @ src;

public void findClones(loc project) {
	set[Declaration] asts = createAstsFromEclipseProject(project, false);
	
	list[list[tuple[str, loc]]] tokensAndLocations = [];
	list[loc] files = [];
	
	for (ast <- asts) {
		files += ast@src;
		tokensAndLocations += [tokenize(ast)];
		//println({token | <token, l> <- tokenize(ast), l == |file:///unknown|});
	}
	
	list[list[str]] tokens = [[t | <t, _> <- tokenList] | tokenList <- tokensAndLocations];
		
	map[list[str], list[tuple[int, int]]] blocks = splitInBlocksOf(tokens, 60);
	set[tuple[tuple[int,int], tuple[int,int], int]] expandedClonedBlocks = expandClonedBlocks(blocks, 60);
	
	for (expandedClonedBlock <- expandedClonedBlocks) {
		<<fId1, tokenNumber1>, <fId2, tokenNumber2>, cloneSize> = expandedClonedBlock;
		clone1Loc1 = tokensAndLocations[fId1][tokenNumber1][1];
		println(size(tokensAndLocations[fId1]));
		clone1Loc2 = tokensAndLocations[fId1][tokenNumber1 + cloneSize - 2][1];
		
		clone2Loc1 = tokensAndLocations[fId2][tokenNumber2][1];
		println(size(tokensAndLocations[fId2]));
		println(tokenNumber2);
		println(cloneSize);
		clone2Loc2 = tokensAndLocations[fId2][tokenNumber2 + cloneSize - 2][1];
		
		loc1 = totalCoverage([clone1Loc1, clone1Loc2]);
		loc2 = totalCoverage([clone2Loc1, clone2Loc2]);
		//println(<fId1, tokenNumber1>);
		println(clone1Loc1);
		println(clone1Loc2);
		//println(<fId2, tokenNumber2>);
		println(clone2Loc1);
		println(clone2Loc2);
		//println(loc1);
		//println(loc2);
		//println(readFile(loc1));
		//println(readFile(loc2));
	}
	
	set[list[tuple[int, int]]] cloneBlocks = clonedBlocks(blocks, 60);
	set[tuple[int, int]] cloneTokens = clonedLines(blocks, 60);
	
	for (<fId, tokenNumber> <- sort([c | c <- cloneTokens])) {
		//println("<tokensAndLocations[fId][tokenNumber][0]> <files[fId]> <tokensAndLocations[fId][tokenNumber][1]>");
		;//println(tokens[fId][tokenNumber]);
	}
	
	println(size(cloneTokens));
}

public set[tuple[tuple[int,int], tuple[int,int], int]] expandClonedBlocks(blocks, blockSize) {
	set[list[tuple[int, int]]] cloneBlocks = clonedBlocks(blocks, blockSize);
	
	map[tuple[int, int], set[tuple[int, int]]] cloneBlockRelations = ();
	for (list[tuple[int, int]] cloneBlock <- cloneBlocks) {
		for (i <- [0 .. size(cloneBlock)]) {
			cloneBlockRelations[cloneBlock[i]] = {clone | clone <- cloneBlock[..i] + cloneBlock[i + 1..]};
		}
	}
	
	set[tuple[tuple[int,int], tuple[int,int], int]] expandedClonedBlocks = {};
	
	for (tuple[int, int] clone <- cloneBlockRelations) {
		set[tuple[int, int]] otherClones = {};
		set[tuple[int, int]] potentialOtherClones = cloneBlockRelations[clone];
		
		for (tuple[int, int] otherClone <- potentialOtherClones) {
			tuple[int, int] previousOtherClone = <otherClone[0], otherClone[1] - 1>;
			
			if (!(previousOtherClone in cloneBlockRelations)) {
				otherClones += otherClone;
				continue;
			}
			
			if (!(clone in cloneBlockRelations[previousOtherClone])) {
				otherClones += otherClone;
				continue;
			}
		}
		
		if (size(otherClones) > 0) {
			int cloneSize = blockSize;
			tuple[int, int] nextClone = <clone[0], clone[1]>;
			set[tuple[int, int]] nextOtherClones = otherClones;
			set[tuple[int, int]] potentialNextOtherClones = nextOtherClones;
		
			while (size(nextOtherClones) > 0) {
				cloneSize += 1;
				nextClone = <nextClone[0], nextClone[1] + 1>;
				potentialNextOtherClones = {<oc[0], oc[1] + 1> | oc <- nextOtherClones};
				nextOtherClones = {};
				
				for (tuple[int, int] nextOtherClone <- potentialNextOtherClones) {
					if (nextOtherClone in cloneBlockRelations && nextClone in cloneBlockRelations[nextOtherClone]) {
						nextOtherClones += nextOtherClone;
					}
				}
			}
			
			cloneSize -= 1;
			nextOtherClones = potentialNextOtherClones;
			
			for (nextOtherClone <- nextOtherClones) {
				expandedClonedBlocks += <clone, <nextOtherClone[0], nextOtherClone[1] - (cloneSize - blockSize)>, cloneSize>;
			}
		}
	}
	
	return expandedClonedBlocks;
}

public Declaration fixSrcs(Declaration ast) {
	loc lastSrc = ast@src;
	
	return top-down visit(ast) {
		case v:variables(_, _): {
			list[loc] srcs = [];
			for (Type variable <- v) {
				if (!("src" in getAnnotations(variable))) {
					variable@src = lastSrc;
				}
				srcs += variable@src;	
			}
			v@src = totalCoverage(srcs);
		}
		case Type e: {
			if (!("src" in getAnnotations(e))) {
				e@src = lastSrc;
			}	
		}
		case Declaration e: {
			lastSrc = e@src;
		}
		case Expression e: {
			lastSrc = e@src;
		}
		case Statement e: {
			lastSrc = e@src;
		}
		case Modifier e: {
			lastSrc = e@src;
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
	loc total = locs[0];
	loc last = locs[size(locs)-1];
	total.end.line = last.end.line;
	total.end.column = last.end.column;
	total.length = (0 | it + location.length | location <- locs);
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