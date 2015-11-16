module QualityCharacteristic

import Rank;
import Set;
import SourceProperty;

public data QualityCharacteristic =
	Analysability()
  | Changeability()
  | Testability()
  | Maintainability();
 

public set[SourceProperty] relevantSourceProperties(Analysability())
	= {Volume(), Duplication(), UnitSize()};
	
public set[SourceProperty] relevantSourceProperties(Changeability())
	= {UnitComplexity(), Duplication()};
	
public set[SourceProperty] relevantSourceProperties(Testability())
	= {UnitComplexity(), UnitSize()};
	
public set[SourceProperty] relevantSourceProperties(Maintainability())
	= union({relevantSourceProperties(Analysability())
			,relevantSourceProperties(Changeability())
			,relevantSourceProperties(Testability())});

			
public Rank rank(Maintainability(), map[SourceProperty, Rank] propertyRanks)
	= average([rank(characteristic, propertyRanks) | characteristic <- [Analysability(), Changeability(), Testability()]]);

public default Rank rank(QualityCharacteristic characteristic, map[SourceProperty, Rank] propertyRanks)
	= average([propertyRanks[property] | property <- relevantSourceProperties(characteristic)]);

private map[SourceProperty, Rank] fig5test = (
	Volume() : Excellent(),
	UnitComplexity() : Dismal(),
	Duplication() : Bad(),
	UnitSize() : Bad()
);

test bool testRank1() = rank(Analysability(), fig5test) == Neutral();
test bool testRank2() = rank(Changeability(), fig5test) == Bad();
test bool testRank3() = rank(Testability(), fig5test) == Bad();
test bool testRank4() = rank(Maintainability(), fig5test) == Bad();