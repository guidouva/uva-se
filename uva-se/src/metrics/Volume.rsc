module metrics::Volume

import IO;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import Metric;
import Rank;

import metrics::helpers::Model;
import metrics::helpers::Code;

public tuple[Rank,Metric] rank(M3 model) {
	\loc = LOC(model);
	return <rank(\loc), \loc>;
}

public Rank rank(LinesOfCode(linesOfCode)) {
	if (linesOfCode <= 66 * 1000)
		return Excellent();
	if (linesOfCode <= 246 * 1000)
		return Good();
	if (linesOfCode <= 665 * 1000)
		return Neutral();
	if (linesOfCode <= 1310 * 1000)
		return Bad();
	return Dismal();
}

public Metric LOC(M3 model) =
	LinesOfCode( LOC(("" | it + readFile(l)+"\n" | l <- compilationUnits(model))) );
	
private M3 modelTest = createM3FromEclipseProject(|project://volume-test|);

test bool testRank() = rank(modelTest) == <Excellent(), LinesOfCode(18)>;