module metrics::Rank

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import util::Math;
import IO;

import metrics::Volume;
import metrics::CyclomaticComplexity;

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

public rank rankCC(M3 model) {
	list[tuple[int, int]] cc = totalMethodCyclomaticComplexity(model);
	
	nLinesInMethods 	= (0 | it + linesOfCode | <_, linesOfCode> <- cc);
	nLinesInModerate 	= (0 | it + linesOfCode | 
							<complexity, linesOfCode> <- cc, complexity >= 11 && complexity <= 20);
	nLinesInHigh 		= (0 | it + linesOfCode |
							<complexity, linesOfCode> <- cc, complexity >= 21 && complexity <= 50);
	nLinesInVeryHigh 	= (0 | it + linesOfCode |
							<complexity, linesOfCode> <- cc, complexity > 50);
	
	real moderatePercentage = (nLinesInModerate * 1.0) / nLinesInMethods;
	real highPercentage 	= (nLinesInHigh * 1.0) / nLinesInMethods;
	real veryHighPercentage = (nLinesInVeryHigh * 1.0) / nLinesInMethods;
	
	//println("CC -\> Moderate: <moderatePercentage>%, High: <highPercentage>%, Very High: <veryHighPercentage>%");
	//println("CC LOC -\> Moderate: <nLinesInModerate>, High: <nLinesInHigh>, Very High: <nLinesInVeryHigh>");
	
	if (moderatePercentage < 25 && ceil(highPercentage) == 0 && ceil(veryHighPercentage) == 0)
		return excellent();
	if (moderatePercentage < 30 && highPercentage < 5 && ceil(veryHighPercentage) == 0)
		return good();
	if (moderatePercentage < 40 && highPercentage < 10 && ceil(veryHighPercentage) == 0)
		return neutral();
	if (moderatePercentage < 50 && highPercentage < 15 && veryHighPercentage < 5)
		return bad();
	return dismal();
}

test bool testRankCC() =
	rankCC(createM3FromEclipseProject(|project://cc-test|)) == excellent();
	
test bool testRankVolume() =
	rankVolume(createM3FromEclipseProject(|project://volume-test|)) == excellent();