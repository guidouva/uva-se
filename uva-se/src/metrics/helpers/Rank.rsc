module metrics::helpers::Rank

import Rank;
import util::Math;

public Rank rankUnits(int moderateThreshold, int highThreshold, int veryHighThreshold,
					  list[tuple[int,int]] unitDataAndLOC) {
	nLinesInMethods 	= (0 | it + linesOfCode | <_, linesOfCode> <- unitDataAndLOC);
	nLinesInModerate 	= (0 | it + linesOfCode | 
							<\data, linesOfCode> <- unitDataAndLOC, \data > moderateThreshold, \data <= highThreshold);
	nLinesInHigh 		= (0 | it + linesOfCode |
							<\data, linesOfCode> <- unitDataAndLOC, \data > highThreshold, \data <= veryHighThreshold);
	nLinesInVeryHigh 	= (0 | it + linesOfCode |
							<\data, linesOfCode> <- unitDataAndLOC, \data > veryHighThreshold);
	
	real moderatePercentage = (nLinesInModerate * 1.0) / nLinesInMethods;
	real highPercentage 	= (nLinesInHigh * 1.0) / nLinesInMethods;
	real veryHighPercentage = (nLinesInVeryHigh * 1.0) / nLinesInMethods;
	
	//println("CC -\> Moderate: <moderatePercentage>%, High: <highPercentage>%, Very High: <veryHighPercentage>%");
	//println("CC LOC -\> Moderate: <nLinesInModerate>, High: <nLinesInHigh>, Very High: <nLinesInVeryHigh>");
	
	if (moderatePercentage < 25 && ceil(highPercentage) == 0 && ceil(veryHighPercentage) == 0)
		return Excellent();
	if (moderatePercentage < 30 && highPercentage < 5 && ceil(veryHighPercentage) == 0)
		return Good();
	if (moderatePercentage < 40 && highPercentage < 10 && ceil(veryHighPercentage) == 0)
		return Neutral();
	if (moderatePercentage < 50 && highPercentage < 15 && veryHighPercentage < 5)
		return Bad();

	return Dismal();
}