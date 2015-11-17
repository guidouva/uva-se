module Metric

import util::Math;


public data Metric =
	RiskProfile(real low, real moderate, real high, real veryHigh)
  | LinesOfCode(int \loc);


public str toString(RiskProfile(low,moderate,high,veryHigh))
	= "risk profile (low = <percent(low)>%, "
	+ "moderate = <percent(moderate)>%, "
	+ "high = <percent(high)>%, "
	+ "very high = <percent(veryHigh)>%)";

public str toString(LinesOfCode(x)) = "lines of code = <x>";

private num percent(real fraction) = round(fraction*100, 0.1);
