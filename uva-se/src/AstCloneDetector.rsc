module AstCloneDetector

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Node;
import IO;
import List;
import Set;
import Relation;

import metrics::Duplication;

anno loc Type @ src;

alias fid_t = int;
alias tokenindex_t = int;
alias token_t = str;
alias tokenlocation_t = tuple[fid_t,tokenindex_t];
alias block_t = list[token_t];

public void findClones(loc project) {
	set[Declaration] asts = createAstsFromEclipseProject(project, false);
	
	list[list[token_t]] tokens = [];
	
	for (ast <- asts) {
		tokens += [[token | <token, _> <- tokenize(ast)]];
		println({token | <token, l> <- tokenize(ast), l == |file://NOTHING|});
	}
	
	map[block_t, list[tokenlocation_t]] blocks = splitInBlocksOf(tokens, 60);
	rel[tokenlocation_t, tokenlocation_t] cloneBlocks = clonedBlocks(blocks, 60);
	set[tokenlocation_t] cloneTokens = clonedLines(blocks, 60);
	
	for (<fId, tokenNumber> <- sort([c | c <- cloneTokens])) {
		;//println(tokens[fId][tokenNumber]);
	}
	
	println(size(cloneTokens));
}

public node fixSrcs(Declaration ast) {
	loc lastSrc = ast@src;
	
	return bottom-up visit(ast) {
		case v:variables(_, _): {
			list[loc] srcs = [];
			for (variable <- v) {
				println(variable);
				srcs += variable@src;	
			}
			v@src = totalCoverage(srcs);
		}
		case Type e: {
		
			println(e);
			e@src ? lastSrc;
			println(e);
		}
		case Declaration e: {
			lastSrc = e@src;
		}
	};
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
private map[block_t, list[tokenlocation_t]] splitInBlocksOf(list[list[token_t]] tokensList, int blockSize) {
	map[block_t, list[blocklocation_t]] blocks = ();
	
	for (i <- [0 .. size(tokensList)]) {
		list[token] tokens = tokensList[i];
		
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
				if (max(tokenNumbers) - min(tokenNumbers) < blockSize) {
					continue;
				}
			}
				
			clones += { <l1,l2> | l1 <- locations, l2 <- locations, l1 != l2 };
		}
	}
	
	return clones + invert(clones);
}

private set[tokenlocation_t] clonedLines(map[block_t, list[tokenlocation_t]] blocks, int blockSize) {
	set[tokenlocation_t] clones = {};
	
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