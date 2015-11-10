module metrics::CyclicComplexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import IO;
import String;
import Set;

import metrics::ModelHelpers;
import metrics::CodeHelpers;

public int cyclicComplexity(M3 model) {
	complexity = (0 | it + cyclicComplexity(unit, model) | unit <- methods(model));
	return complexity;
}

public int cyclicComplexity(loc file, M3 model) {
	ast = getMethodASTEclipse(file, model = model);
	int count = 1;
	
	visit (ast) {
	    case \for(_, expr, _, _):
	    	count += expressionComplexity(expr);
	    case \while(expr, _):
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

bool testCcMethod(loc method, int expectedCc) {
	model = createM3FromEclipseProject(|project://cc-test|);
	actualCc = cyclicComplexity(method, model);
	println("\<<expectedCc>,<actualCc>\> <method>");
	return actualCc == expectedCc;
}

test bool testCcSeq() = testCcMethod(|java+method:///Main/seq(int,int)|, 1);
test bool testCcTheif() = testCcMethod(|java+method:///Main/theif(int,int)|, 2);
test bool testCcIfelse() = testCcMethod(|java+method:///Main/ifelse(int,int)|, 2);
test bool testCcIfelseif() = testCcMethod(|java+method:///Main/ifelseif(int,int)|, 3);
test bool testCcIfelseifelse() = testCcMethod(|java+method:///Main/ifelseifelse(int,int)|, 3);
test bool testCcIfand() = testCcMethod(|java+method:///Main/ifand(int,int)|, 3);
test bool testCcIfor() = testCcMethod(|java+method:///Main/ifor(int,int)|, 3);
test bool testCcIfandor() = testCcMethod(|java+method:///Main/ifandor(int,int)|, 4);
test bool testCcIforand() = testCcMethod(|java+method:///Main/iforand(int,int)|, 4);
test bool testCcNestedif() = testCcMethod(|java+method:///Main/nestedif(int,int)|, 3);
test bool testCcSwitch1() = testCcMethod(|java+method:///Main/switch1(int,int)|, 2);
test bool testCcSwitch1default() = testCcMethod(|java+method:///Main/switch1default(int,int)|, 2);
test bool testCcSwitch2() = testCcMethod(|java+method:///Main/switch2(int,int)|, 3);
test bool testCcSwitch2nobreak() = testCcMethod(|java+method:///Main/switch2nobreak(int,int)|, 3);
test bool testCcSwitch2default() = testCcMethod(|java+method:///Main/switch2default(int,int)|, 3);
test bool testCcNestedswitch() = testCcMethod(|java+method:///Main/nestedswitch(int,int)|, 3);
test bool testCcCond() = testCcMethod(|java+method:///Main/cond(int,int)|, 2);
test bool testCcCondand() = testCcMethod(|java+method:///Main/condand(int,int)|, 3);
test bool testCcCondor() = testCcMethod(|java+method:///Main/condor(int,int)|, 3);
test bool testCcCondandor() = testCcMethod(|java+method:///Main/condandor(int,int)|, 4);
test bool testCcCondorand() = testCcMethod(|java+method:///Main/condorand(int,int)|, 4);
test bool testCcNestedcond() = testCcMethod(|java+method:///Main/nestedconf(int,int)|, 3);
test bool testCcForin() = testCcMethod(|java+method:///Main/forin(int,int)|, 2);
test bool testCcSimplewhile() = testCcMethod(|java+method:///Main/simplewhile(int,int)|, 2);