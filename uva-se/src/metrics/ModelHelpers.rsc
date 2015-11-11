module metrics::ModelHelpers

import Relation;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public set[loc] compilationUnits(M3 model) =
	{ l | l <- domain(model@containment), l.scheme == "java+compilationUnit" };
	
public set[Declaration] methodDeclarations(Declaration ast) {
	m = {};
	
	visit (ast) {
	case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):
		m += \method(\return, name, parameters, exceptions, impl);	
	case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions):
		m += \method(\return, name, parameters, exceptions);	
	}
	
	return m;
}