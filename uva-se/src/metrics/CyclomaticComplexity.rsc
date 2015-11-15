module metrics::CyclomaticComplexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import IO;

import Rank;
import metrics::helpers::Model;
import metrics::helpers::Code;
import metrics::helpers::Rank;

public Rank rank(M3 model) = rank(cyclomaticComplexityPerMethod(model));
public Rank rank(loc project) = rank(cyclomaticComplexityPerMethod(project));

public Rank rank(list[tuple[int,int]] unitCCsAndLOC) = 
	rankUnits(10, 20, 50, unitCCsAndLOC);

public list[tuple[int,int]] cyclomaticComplexityPerMethod(M3 model) {
	asts = [ getMethodASTEclipse(method, model = model) | method <- methods(model) ];
	return cyclomaticComplexityPerUnit(asts);
}

// you can use this one for large projects as it uses less stack space than cyclomaticComplexityPerMethod(M3)
public list[tuple[int,int]] cyclomaticComplexityPerMethod(loc project) {
	asts = createAstsFromDirectory(project, false);
	methodAsts = ([] | it + methodDeclarations(ast) | ast <- asts);
	return cyclomaticComplexityPerUnit(methodAsts);
}

private list[tuple[int,int]] cyclomaticComplexityPerUnit(list[Declaration] asts) =
	[ <cyclomaticComplexity(ast), LOC(ast@src)> | ast <- asts ];

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

test bool testCcAssertand() = testCcMethod(|java+method:///Main/assertand(int,int)|, 3);
test bool testCcAssertandor() = testCcMethod(|java+method:///Main/assertandor(int,int)|, 4);
test bool testCcAssertor() = testCcMethod(|java+method:///Main/assertor(int,int)|, 3);
test bool testCcAssertorand() = testCcMethod(|java+method:///Main/assertorand(int,int)|, 4);

test bool testCcCond() = testCcMethod(|java+method:///Main/cond(int,int)|, 2);
test bool testCcCondand() = testCcMethod(|java+method:///Main/condand(int,int)|, 3);
test bool testCcCondandor() = testCcMethod(|java+method:///Main/condandor(int,int)|, 4);
test bool testCcCondor() = testCcMethod(|java+method:///Main/condor(int,int)|, 3);
test bool testCcCondorand() = testCcMethod(|java+method:///Main/condorand(int,int)|, 4);

test bool testCcDoand() = testCcMethod(|java+method:///Main/doand(int,int)|, 3);
test bool testCcDoandor() = testCcMethod(|java+method:///Main/doandor(int,int)|, 4);
test bool testCcDoor() = testCcMethod(|java+method:///Main/door(int,int)|, 3);
test bool testCcDoorand() = testCcMethod(|java+method:///Main/doorand(int,int)|, 4);

test bool testCcForand() = testCcMethod(|java+method:///Main/forand(int,int)|, 3);
test bool testCcForandor() = testCcMethod(|java+method:///Main/forandor(int,int)|, 4);
test bool testCcForin() = testCcMethod(|java+method:///Main/forin(int,int)|, 2);
test bool testCcForor() = testCcMethod(|java+method:///Main/foror(int,int)|, 3);
test bool testCcFororand() = testCcMethod(|java+method:///Main/fororand(int,int)|, 4);

test bool testCcIfand() = testCcMethod(|java+method:///Main/ifand(int,int)|, 3);
test bool testCcIfandor() = testCcMethod(|java+method:///Main/ifandor(int,int)|, 4);
test bool testCcIfelse() = testCcMethod(|java+method:///Main/ifelse(int,int)|, 2);
test bool testCcIfelseif() = testCcMethod(|java+method:///Main/ifelseif(int,int)|, 3);
test bool testCcIfelseifelse() = testCcMethod(|java+method:///Main/ifelseifelse(int,int)|, 3);
test bool testCcIfor() = testCcMethod(|java+method:///Main/ifor(int,int)|, 3);
test bool testCcIforand() = testCcMethod(|java+method:///Main/iforand(int,int)|, 4);

test bool testCcMain() = testCcMethod(|java+method:///Main/main(java.lang.String%5B%5D)|, 1);

test bool testCcNestedcond() = testCcMethod(|java+method:///Main/nestedcond(int,int)|, 3);
test bool testCcNesteddo() = testCcMethod(|java+method:///Main/nesteddo(int,int)|, 3);
test bool testCcNestedfor() = testCcMethod(|java+method:///Main/nestedfor(int,int)|, 3);
test bool testCcNestedif() = testCcMethod(|java+method:///Main/nestedif(int,int)|, 3);
test bool testCcNestedswitch() = testCcMethod(|java+method:///Main/nestedswitch(int,int)|, 3);
test bool testCcNestedwhile() = testCcMethod(|java+method:///Main/nestedwhile(int,int)|, 3);

test bool testCcSeq() = testCcMethod(|java+method:///Main/seq(int,int)|, 1);

test bool testCcSimpleassert() = testCcMethod(|java+method:///Main/simpleassert(int,int)|, 2);
test bool testCcSimpledo() = testCcMethod(|java+method:///Main/simpledo(int,int)|, 2);
test bool testCcSimplefor() = testCcMethod(|java+method:///Main/simplefor(int,int)|, 2);
test bool testCcSimplewhile() = testCcMethod(|java+method:///Main/simplewhile(int,int)|, 2);

test bool testCcSwitch1() = testCcMethod(|java+method:///Main/switch1(int,int)|, 2);
test bool testCcSwitch1default() = testCcMethod(|java+method:///Main/switch1default(int,int)|, 2);
test bool testCcSwitch2() = testCcMethod(|java+method:///Main/switch2(int,int)|, 3);
test bool testCcSwitch2default() = testCcMethod(|java+method:///Main/switch2default(int,int)|, 3);
test bool testCcSwitch2nobreak() = testCcMethod(|java+method:///Main/switch2nobreak(int,int)|, 3);

test bool testCcTheif() = testCcMethod(|java+method:///Main/theif(int,int)|, 2);

test bool testCcTrycatch() = testCcMethod(|java+method:///Main/trycatch(int,int)|, 2);
test bool testCcTrycatchcatch() = testCcMethod(|java+method:///Main/trycatchcatch(int,int)|, 3);
test bool testCcTrycatchcatchfinally() = testCcMethod(|java+method:///Main/trycatchcatchfinally(int,int)|, 3);
test bool testCcTrycatchfinally() = testCcMethod(|java+method:///Main/trycatchfinally(int,int)|, 2);
test bool testCcTryfinally() = testCcMethod(|java+method:///Main/tryfinally(int,int)|, 1);

test bool testCcUnconditionalfor() = testCcMethod(|java+method:///Main/unconditionalfor(int,int)|, 1);

test bool testCcWhileand() = testCcMethod(|java+method:///Main/whileand(int,int)|, 3);
test bool testCcWhileandor() = testCcMethod(|java+method:///Main/whileandor(int,int)|, 4);
test bool testCcWhileor() = testCcMethod(|java+method:///Main/whileor(int,int)|, 3);
test bool testCcWhileorand() = testCcMethod(|java+method:///Main/whileorand(int,int)|, 4);

test bool testRank() = rank(modelTest) == Excellent();