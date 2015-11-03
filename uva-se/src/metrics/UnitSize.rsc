module metrics::UnitSize

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import metrics::Volume;
import Relation;
import Set;

public real compilationUnitLOC(str project) {
	model = createM3FromEclipseProject(|project://<project>|);
	units = {l | l <- domain(model@containment), l.scheme == "java+compilationUnit"};
	return (0.0 | it + LOC(unit) | unit <- units);
}