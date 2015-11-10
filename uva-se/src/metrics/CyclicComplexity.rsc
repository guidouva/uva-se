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
	println(complexity);
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
	visit (expression) {
		case \infix(lExpr, "&&", rExpr):
			return expressionComplexity(lExpr) + expressionComplexity(rExpr);
		case \infix(lExpr, "||", rExpr):
			return expressionComplexity(lExpr) + expressionComplexity(rExpr);
	}
	
	return 1;
}

test bool testCyclicComplexity() =
	cyclicComplexity(createM3FromEclipseProject(|project://duplication-test|)) == 4;