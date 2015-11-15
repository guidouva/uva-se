module metrics::Volume

import IO;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import Rank;
import metrics::helpers::Model;
import metrics::helpers::Code;

public Rank rank(M3 model) = rank(LOC(model));

public Rank rank(int linesOfCode) {
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

public int LOC(M3 model) =
	(0 | it + LOC(readFile(l)) | l <- compilationUnits(model));
	
private M3 modelTest = createM3FromEclipseProject(|project://volume-test|);

test bool testLOC() = LOC(modelTest) == 18;
test bool testRank() = rank(modelTest) == Excellent();