module Rank

import List;

public data Rank =
	Excellent()
  | Good()
  | Neutral()
  | Bad()
  | Dismal();
  

public Rank average(list[Rank] ranks) {
	int sum = (0 | it + fromRank(r) | r <- ranks);
	return toRank(sum * 1.0 / size(ranks));
}

public int fromRank(Excellent()) = 2;
public int fromRank(Good())      = 1;
public int fromRank(Neutral())   = 0;
public int fromRank(Bad())       = -1;
public int fromRank(Dismal())    = -2;

public Rank toRank(num rank) {
	if(rank < -1.5) return Dismal();
	if(rank < -0.5) return Bad();
	if(rank < 0.5) return Neutral();
	if(rank < 1.5) return Good();
	return Excellent();
}

test bool avg1() = average([Excellent(), Bad(), Bad(), Neutral()]) == Neutral();
test bool avg2() = average([Dismal(), Bad()]) == Bad();
test bool avg3() = average([Neutral()]) == Neutral();
test bool avg4() = average([Dismal(), Bad(), Neutral()]) == Bad();