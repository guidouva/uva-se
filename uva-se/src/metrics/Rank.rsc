module metrics::Rank

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import metrics::Volume;

public data rank =
	excellent()
  | good()
  | neutral()
  | bad()
  | dismal();
  
public rank rankVolume(M3 model) {
	linesOfCode = LOC(model);
	
	if (linesOfCode <= 66 * 1000)
		return excellent();
	if (linesOfCode <= 246 * 1000)
		return good();
	if (linesOfCode <= 665 * 1000)
		return neutral();
	if (linesOfCode <= 1310 * 1000)
		return bad();
	return dismal();
}

test bool testRankVolume() =
	rankVolume(createM3FromEclipseProject(|project://volume-test|)) == excellent();