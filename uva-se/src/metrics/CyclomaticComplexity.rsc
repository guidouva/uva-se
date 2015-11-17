module metrics::CyclomaticComplexity

import Set;
import List;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Metric;
import Rank;

import metrics::helpers::Model;
import metrics::helpers::Code;
import metrics::helpers::Rank;

public tuple[Rank,Metric] rank(M3 model) = rank(cyclomaticComplexityPerMethod(model));

public tuple[Rank,Metric] rank(list[tuple[int,int]] unitCCsAndLOC) = 
	rankUnits(10, 20, 50, unitCCsAndLOC);

public list[tuple[int,int]] cyclomaticComplexityPerMethod(M3 model) {
	asts = createAstsFromEclipseProject(model.id, false);
	methodAsts = ([] | it + toList(methodDeclarationsWithBody(ast)) | ast <- asts);
	return cyclomaticComplexityPerUnit(methodAsts);
}

private list[tuple[int,int]] cyclomaticComplexityPerUnit(list[Declaration] asts) {
	srcs = [ast@src | ast <- asts];
	locs = LOC(srcs);
	
	list[tuple[int, int]] ccPerUnit = [];
	for (i <- [0 .. size(asts)]) {
		ccPerUnit += <cyclomaticComplexity(asts[i]), locs[i]>;
	}
	return ccPerUnit;
}

private int cyclomaticComplexity(Declaration ast) {
	int count = 1;
	
	visit (ast) {
	    case \for(_, expr, _, _):
	    	count += expressionComplexity(expr);
	    case \while(expr, _):
	    	count += expressionComplexity(expr);
	    case \do(_, expr):
	    	count += expressionComplexity(expr);
	    case \if(expr, _):
	    	count += expressionComplexity(expr);
		case \if(expr, _, _):
	    	count += expressionComplexity(expr);
	    case \conditional(expr, _, _):
	    	count += expressionComplexity(expr);
	   	case \foreach(_, expr, _):
	   		count += expressionComplexity(expr);
	   	case \assert(expr):
	   		count += expressionComplexity(expr);
	   	case \assert(expr, _):
	   		count += expressionComplexity(expr);
	   	case \catch(_, _):
	   		count += 1; 
	   	case \case(expr):
	   		count += expressionComplexity(expr);
	}

	return count;
}

private int expressionComplexity(Expression expression) {
	count = 1;
	
	visit (expression) {
		case \infix(lExpr, "&&", rExpr):
			count += 1;
		case \infix(lExpr, "||", rExpr):
			count += 1;
	}
	
	return count;
}

private M3 modelTest = createM3FromEclipseProject(|project://cc-test|);

private bool testCcMethod(loc method, int expectedCc) {
	ast = getMethodASTEclipse(method, model = modelTest);
	actualCc = cyclomaticComplexity(ast);
	//println("\<expected <expectedCc>, got <actualCc>\> <method>");
	return actualCc == expectedCc;
}

test bool testCcAssertand() = testCcMethod(|java+method:///CCMain/assertand(int,int)|, 3);
test bool testCcAssertandor() = testCcMethod(|java+method:///CCMain/assertandor(int,int)|, 4);
test bool testCcAssertor() = testCcMethod(|java+method:///CCMain/assertor(int,int)|, 3);
test bool testCcAssertorand() = testCcMethod(|java+method:///CCMain/assertorand(int,int)|, 4);

test bool testCcCond() = testCcMethod(|java+method:///CCMain/cond(int,int)|, 2);
test bool testCcCondand() = testCcMethod(|java+method:///CCMain/condand(int,int)|, 3);
test bool testCcCondandor() = testCcMethod(|java+method:///CCMain/condandor(int,int)|, 4);
test bool testCcCondor() = testCcMethod(|java+method:///CCMain/condor(int,int)|, 3);
test bool testCcCondorand() = testCcMethod(|java+method:///CCMain/condorand(int,int)|, 4);

test bool testCcDoand() = testCcMethod(|java+method:///CCMain/doand(int,int)|, 3);
test bool testCcDoandor() = testCcMethod(|java+method:///CCMain/doandor(int,int)|, 4);
test bool testCcDoor() = testCcMethod(|java+method:///CCMain/door(int,int)|, 3);
test bool testCcDoorand() = testCcMethod(|java+method:///CCMain/doorand(int,int)|, 4);

test bool testCcForand() = testCcMethod(|java+method:///CCMain/forand(int,int)|, 3);
test bool testCcForandor() = testCcMethod(|java+method:///CCMain/forandor(int,int)|, 4);
test bool testCcForin() = testCcMethod(|java+method:///CCMain/forin(int,int)|, 2);
test bool testCcForor() = testCcMethod(|java+method:///CCMain/foror(int,int)|, 3);
test bool testCcFororand() = testCcMethod(|java+method:///CCMain/fororand(int,int)|, 4);

test bool testCcIfand() = testCcMethod(|java+method:///CCMain/ifand(int,int)|, 3);
test bool testCcIfandor() = testCcMethod(|java+method:///CCMain/ifandor(int,int)|, 4);
test bool testCcIfelse() = testCcMethod(|java+method:///CCMain/ifelse(int,int)|, 2);
test bool testCcIfelseif() = testCcMethod(|java+method:///CCMain/ifelseif(int,int)|, 3);
test bool testCcIfelseifelse() = testCcMethod(|java+method:///CCMain/ifelseifelse(int,int)|, 3);
test bool testCcIfor() = testCcMethod(|java+method:///CCMain/ifor(int,int)|, 3);
test bool testCcIforand() = testCcMethod(|java+method:///CCMain/iforand(int,int)|, 4);

test bool testCcCCMain() = testCcMethod(|java+method:///CCMain/main(java.lang.String%5B%5D)|, 1);

test bool testCcNestedcond() = testCcMethod(|java+method:///CCMain/nestedcond(int,int)|, 3);
test bool testCcNesteddo() = testCcMethod(|java+method:///CCMain/nesteddo(int,int)|, 3);
test bool testCcNestedfor() = testCcMethod(|java+method:///CCMain/nestedfor(int,int)|, 3);
test bool testCcNestedif() = testCcMethod(|java+method:///CCMain/nestedif(int,int)|, 3);
test bool testCcNestedswitch() = testCcMethod(|java+method:///CCMain/nestedswitch(int,int)|, 3);
test bool testCcNestedwhile() = testCcMethod(|java+method:///CCMain/nestedwhile(int,int)|, 3);

test bool testCcSeq() = testCcMethod(|java+method:///CCMain/seq(int,int)|, 1);

test bool testCcSimpleassert() = testCcMethod(|java+method:///CCMain/simpleassert(int,int)|, 2);
test bool testCcSimpledo() = testCcMethod(|java+method:///CCMain/simpledo(int,int)|, 2);
test bool testCcSimplefor() = testCcMethod(|java+method:///CCMain/simplefor(int,int)|, 2);
test bool testCcSimplewhile() = testCcMethod(|java+method:///CCMain/simplewhile(int,int)|, 2);

test bool testCcSwitch1() = testCcMethod(|java+method:///CCMain/switch1(int,int)|, 2);
test bool testCcSwitch1default() = testCcMethod(|java+method:///CCMain/switch1default(int,int)|, 2);
test bool testCcSwitch2() = testCcMethod(|java+method:///CCMain/switch2(int,int)|, 3);
test bool testCcSwitch2default() = testCcMethod(|java+method:///CCMain/switch2default(int,int)|, 3);
test bool testCcSwitch2nobreak() = testCcMethod(|java+method:///CCMain/switch2nobreak(int,int)|, 3);

test bool testCcTheif() = testCcMethod(|java+method:///CCMain/theif(int,int)|, 2);

test bool testCcTrycatch() = testCcMethod(|java+method:///CCMain/trycatch(int,int)|, 2);
test bool testCcTrycatchcatch() = testCcMethod(|java+method:///CCMain/trycatchcatch(int,int)|, 3);
test bool testCcTrycatchcatchfinally() = testCcMethod(|java+method:///CCMain/trycatchcatchfinally(int,int)|, 3);
test bool testCcTrycatchfinally() = testCcMethod(|java+method:///CCMain/trycatchfinally(int,int)|, 2);
test bool testCcTryfinally() = testCcMethod(|java+method:///CCMain/tryfinally(int,int)|, 1);

test bool testCcUnconditionalfor() = testCcMethod(|java+method:///CCMain/unconditionalfor(int,int)|, 1);

test bool testCcWhileand() = testCcMethod(|java+method:///CCMain/whileand(int,int)|, 3);
test bool testCcWhileandor() = testCcMethod(|java+method:///CCMain/whileandor(int,int)|, 4);
test bool testCcWhileor() = testCcMethod(|java+method:///CCMain/whileor(int,int)|, 3);
test bool testCcWhileorand() = testCcMethod(|java+method:///CCMain/whileorand(int,int)|, 4);

test bool testRank() = rank(modelTest) == <Excellent(), RiskProfile(1.0,0.0,0.0,0.0)>;