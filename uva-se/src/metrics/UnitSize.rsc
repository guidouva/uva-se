module metrics::UnitSize

import Set;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Rank;

import metrics::helpers::Code;
import metrics::helpers::Model;
import metrics::helpers::Rank;

public Rank rank(M3 model) = rank(sizePerMethod(model));

public Rank rank(list[tuple[int,int]] unitSizesAndLOC) = 
	rankUnits(20, 50, 100, unitSizesAndLOC);

public list[tuple[int,int]] sizePerMethod(M3 model) {
	asts = createAstsFromEclipseProject(model.id, false);
	methodAsts = ([] | it + toList(methodDeclarationsWithBody(ast)) | ast <- asts);
	return sizePerUnit(methodAsts);
}

// TODO: weet niet of zo de comments worden gefiltered bij het tellen van regels.
// punt is, LOC(ast@src) is zo ontiegelijk langzaam...
private list[tuple[int,int]] sizePerUnit(list[Declaration] asts) =
	[ <\loc, \loc> | ast <- asts, \loc := ast@src.end.line - ast@src.begin.line ];
	//[ <\loc, \loc> | ast <- asts, \loc := LOC(ast@src) ];
	
private M3 modelTest = createM3FromEclipseProject(|project://volume-test|);
	
test bool testRank() = rank(modelTest) == Excellent();