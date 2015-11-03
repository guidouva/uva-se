module UnitSize

import metrics::Volume;

public real compilationUnitLOC(str project) {
	model = createM3FromEclipseProject(|project://<project>|);
	units = {l | l <- domain(model@containment), l.scheme == "java+compilationUnit"};
	return (0.0 | it + LOC(unit) | unit <- units) / size(units);
}