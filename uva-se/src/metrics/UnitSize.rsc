module metrics::UnitSize

import Set;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import Rank;

import metrics::helpers::Code;
import metrics::helpers::Rank;

public Rank rank(M3 model) = rank(sizePerMethod(model));
public Rank rank(loc project) = rank(sizePerMethod(project));

public Rank rank(list[tuple[int,int]] unitSizesAndLOC) = 
	rankUnits(20, 50, 100, unitSizesAndLOC);

public list[tuple[int,int]] sizePerMethod(M3 model) {
	asts = [ getMethodASTEclipse(method, model = model) | method <- methods(model) ];
	return sizePerUnit(asts);
}

// you can use this one for large projects as it uses less stack space than sizePerMethod(M3)
public list[tuple[int,int]] sizePerMethod(loc project) {
	asts = createAstsFromDirectory(project, false);
	methodAsts = ([] | it + methodDeclarations(ast) | ast <- asts);
	return sizePerUnit(methodAsts);
}

private list[tuple[int,int]] sizePerUnit(list[Declaration] asts) =
	[ <LOC(ast@src), LOC(ast@src)> | ast <- asts  ];
	
private M3 modelTest = createM3FromEclipseProject(|project://volume-test|);
	
test bool testRank() = rank(modelTest) == Excellent();