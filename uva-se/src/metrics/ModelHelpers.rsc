module metrics::ModelHelpers

import Relation;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

public set[loc] compilationUnits(M3 model) =
	{ l | l <- domain(model@containment), l.scheme == "java+compilationUnit" };