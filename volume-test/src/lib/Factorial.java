package lib;


@interface Foo {
	String bar();
	int currentRevision() default 1;
}


/* Calculate the factorial
 * 
 * Functions: calculate
 */
@Foo (
		bar = "someone",
		currentRevision = 3
)
public class Factorial {
	
	// ignore this line
	public static int calculate(int n) { // don't ignore this line
		
		int result = 1;
		for(int i = 2; i <= n; ++i) { /* do not ignore this line
			but ignore this line
		do not ignore this line */ /* still do not ignore this line */ result *= i; // don't ignore this line
		}
		
		return result;

	}

}

// LOC for Volume metric for this file should be: 10