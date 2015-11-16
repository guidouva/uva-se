module metrics::helpers::Model

import Relation;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public set[loc] compilationUnits(M3 model) =
	{ l | l <- domain(model@containment), l.scheme == "java+compilationUnit" };
	
public set[Declaration] methodDeclarationsWithBody(Declaration ast) {
	set[Declaration] methods = {};
	
	visit (ast) {
	case m : \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {
			mm = \method(\return, name, parameters, exceptions, impl);	
			mm@src = m@src;
			methods += mm;
		}
	}
	
	return methods;
}