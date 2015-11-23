module AstCloneDetector

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Node;
import IO;

public void findClones(loc project) {
	set[Declaration] asts = createAstsFromEclipseProject(project, false);
	for (ast <- asts) {
		println(tokenize(ast));
	}
}

public list[str] tokenize(node ast) {
	//model = createM3FromEclipseProject(|project://volume-test|);
	list[str] tokens = [];
	
	top-down visit(ast) {
		case \compilationUnit(_, _): {
			;
		}
		case \compilationUnit(_, _, _): {
			;
		}
		case \import(_): {
			;
		}
		case a:\assignment(lhs, op, rhs): {
			tokens += op;
			if(\simpleName(_) := lhs)
				insert \assignment(\variable("", 0), op, rhs);
		}
		case simpleName(name): {
			tokens += [name];
		}
		case Declaration e: {
			tokens += getName(e);
			//println(getName(e));
		}
		case \infix(_, operator, _): {
			tokens += operator;
		}
		case \postfix(_, operator): {
			tokens += operator;
		}
		case \prefix(operator, _): {
			tokens += operator;
		}
		case Expression e: {
			tokens += getName(e);
			//println(getName(e));
		}
		
		case Statement e: {
			tokens += [getName(e)];
			//println(getName(e));
		}
		
		case Type e: {
			tokens += ["type"];
			//println(getName(e));
		}
	};
	
	return tokens;
}