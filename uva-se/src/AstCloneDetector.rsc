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
import ListRelation;
import String;
import JsValue;

import metrics::Duplication;
import metrics::helpers::Code;

anno loc Type @ src;

alias fid_t = int;
alias tokenindex_t = int;
alias token_t = str;
alias tokenlocation_t = tuple[fid_t,tokenindex_t];
alias block_t = list[token_t];
alias clone_t = tuple[tokenlocation_t,tokenlocation_t,int];

public tuple[set[clone_t], list[list[tuple[token_t, loc]]]] findClones(loc project) {
	println("Loading project");
	set[Declaration] asts = createAstsFromEclipseProject(project, false);
	println("Finished loading project");
	
	return findClones(asts);
}

public tuple[set[clone_t], list[list[tuple[token_t, loc]]]] findClones(set[Declaration] asts) {
	int blockSize = 60;
	
	println("Tokenizing AST");
	list[loc] files = [];
	list[list[tuple[token_t, loc]]] tokensAndLocations = [];
	for (ast <- asts) {
		files += ast@src;
		tokensAndLocations += [tokenize(ast)];
	}
	println("Finished tokenizing AST");
	
	list[list[token_t]] tokens = [[t | <t, _> <- tokenList] | tokenList <- tokensAndLocations];
	map[block_t, list[tokenlocation_t]] blocks = splitInBlocksOf(tokens, blockSize);
	
	println("Finding clones");
	result = <expandClonedBlocks(blocks, blockSize), tokensAndLocations>;
	println("Finished finding clones");
	return result;
}

alias jsobj_t = map[str,value];
alias clonepair_t = tuple[jsobj_t, jsobj_t];

public void writeClones(loc project, loc destination) {
	return writeClones(createAstsFromEclipseProject(project, false), destination);
}

public void writeClones(set[Declaration] asts, loc destination) {
	<blocks, tokensAndLocations> = findClones(asts);
	
	jsobj_t json = ();
	
	//writeFile(destination, "");
	list[str] fileuris = [];
	map[str,int] filesIndex = ();

	list[clonepair_t] clonedata = [];
	
	map[fid_t, int] fileSizes = ();
	map[fid_t, map[fid_t,set[int]]] clonedLinesPerFilePair = ();
	map[fid_t, map[fid_t,real]] duplicationdata = ();
	
	println("Preparing json");
	for (<clone1, clone2, cloneSize> <- blocks) {
		clonepair_t clonepair = <(), ()>;
		tuple[int,set[int],int,set[int]] fileTokens = <0,{},0,{}>;
		
		for (<<fId, tokenNumber>, i> <- [<clone1, 0>, <clone2, 1>]) {
			cloneLocs = [l | <_, l> <- tokensAndLocations[fId][tokenNumber .. tokenNumber + cloneSize - 1]];
			
			loc loc1;
			for (\loc <- cloneLocs) {
				if (\loc != |file:///unknown|) {
					loc1 = \loc;
					break;
				}
			}
			
			loc loc2;
			for (\loc <- reverse(cloneLocs)) {
				if (\loc != |file:///unknown|) {
					loc2 = \loc;
					break;
				}
			}
			
			
			if(loc1.uri notin filesIndex) {
				filesIndex[loc1.uri] = size(fileuris);
				fileuris += loc1.uri;
			}
			
			fIdx = filesIndex[loc1.uri];

			if(fIdx notin fileSizes) fileSizes[fIdx] = size(tokensAndLocations[fId]);
			
			clonepair[i] = (
				"file" : fIdx,
				"begin" : loc1.begin.line,
				"end" : loc2.end.line,
				"text" : getTextBetween(loc1, loc2)
			);

			fileTokens[i*2] = fIdx;
			fileTokens[i*2+1] = toSet([tokenNumber .. tokenNumber + cloneSize - 1]);
		}
		
		clonedata += clonepair;
		
		fids = <fileTokens[0], fileTokens[2]>;
		
		if(fids[0] notin clonedLinesPerFilePair)
			clonedLinesPerFilePair[fids[0]] = ();
		if(fids[1] notin clonedLinesPerFilePair[fids[0]])
			clonedLinesPerFilePair[fids[0]][fids[1]] = {};

		if(fids[1] notin clonedLinesPerFilePair)
			clonedLinesPerFilePair[fids[1]] = ();
		if(fids[0] notin clonedLinesPerFilePair[fids[1]])
			clonedLinesPerFilePair[fids[1]][fids[0]] = {};
		
		clonedLinesPerFilePair[fids[0]][fids[1]] += fileTokens[1];
		clonedLinesPerFilePair[fids[1]][fids[0]] += fileTokens[3];
	}
	
	json["files"] = [ escape(uri, ("\\":"/")) | uri <- fileuris ];
	json["clonedata"] = clonedata;
	json["duplicationdata"] = (
		fid1 : (
			fid2 : toReal(size(clonedLinesPerFilePair[fid1][fid2])) / toReal(fileSizes[fid1])
			| fid2 <- clonedLinesPerFilePair[fid1]
		)
		| fid1 <- clonedLinesPerFilePair
	);
	
	println("Writing to output");
	writeFile(destination, "CLONEDATA = "+toJSON(json)+";");
}

public str getTextBetween(loc loc1, loc loc2) {
	if (loc1 == loc2 || loc1 == |file:///unknown|) {
		return "";
	} 
	
	list[str] lines = [];
	
	i = 1;
	for (line <- readFileLines(toLocation(loc1.uri))) {
		if (i >= loc1.begin.line && i <= loc2.end.line) {
			lines += line;
		}
		else if (i > loc2.end.line) {
			break;
		}
		i += 1;
	}
	
	return intercalate("\n", lines);
}

public set[clone_t] expandClonedBlocks(blocks, blockSize) {
	rel[tokenlocation_t,tokenlocation_t] cloneBlocks = clonedBlocks(blocks, blockSize);
	set[clone_t] expandedClonedBlocks = {};
	
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
		
		while (<nextClone1, nextClone2> in cloneBlocks && nextClone1 != clone2 && nextClone2 != clone1) {
			cloneSize += 1;
			nextClone1 = <nextClone1[0], nextClone1[1] + 1>;
			nextClone2 = <nextClone2[0], nextClone2[1] + 1>;
		}
		expandedClonedBlocks += <clone1, clone2, cloneSize>;
	}
	
	// filter nested clones
	map[tuple[fid_t, fid_t], list[clone_t]] cache = ();
	
	println(expandedClonedBlocks);
	for (clonepair:<clone1, clone2, cloneSize> <- expandedClonedBlocks)  {
		cache[<clone1[0], clone2[0]>] = [];
	}
	println(cache);
	for (clonepair:<clone1, clone2, cloneSize> <- expandedClonedBlocks)  {
		println("<clone1[0]>, <clone2[0]>");
		cache[<clone1[0], clone2[0]>] += clonepair;
	}
	
	set[clone_t] result = {};
	
	for (filepair:<fid1, fid2> <- cache) {
		clonepairs = cache[filepair];
		for (clonepair:<clone1, clone2, cloneSize> <- clonepairs) {
			bool isBiggestBlock = true;
			
			for (otherClonepair:<otherClone1, otherClone2, otherCloneSize> <- clonepairs) {
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
	i = 0;
	for (block <- blocks) {
		locations = blocks[block];
		i += 1;
		if (size(locations) > 1) {
			println("<i> <size(blocks)> <size(locations)>");
			
			tokenNumbers = [tokenNumber | <_, tokenNumber> <- locations];
			
			if (size({fId | <fId, _> <- locations}) == 1) {
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