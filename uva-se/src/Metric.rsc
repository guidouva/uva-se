module Metric

import util::Math;


public data Metric =
	RiskProfile(real low, real moderate, real high, real veryHigh)
  | LinesOfCode(int \loc)
  | DuplicationRatio(real ratio);


public str toString(RiskProfile(low,moderate,high,veryHigh))
	= "risk profile (low = <percent(low)>%, "
	+ "moderate = <percent(moderate)>%, "
	+ "high = <percent(high)>%, "
	+ "very high = <percent(veryHigh)>%)";

public str toString(LinesOfCode(x)) = "lines of code = <x>";

public str toString(DuplicationRatio(x)) = "percentage of duplicate lines of code = <percent(x)>%";

private num percent(real ratio, real roundto = 0.1) = round(ratio*100, roundto);
