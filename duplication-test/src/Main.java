import static java.lang.Math.PI;
import static java.lang.Math.PI;
import static java.lang.Math.PI;
import static java.lang.Math.PI;
import static java.lang.Math.PI;
import static java.lang.Math.PI;
import static java.lang.Math.PI;

public class Main {
	private int x = 3;
	private int y = 3;
	private int z = 3;
	private int a = 3;
	private int b = 3;
	private int c = 3;
	
	public static void main(String[] args) {
		 // begin A
		 System.out.println(Integer.toString(10));
		 System.out.println(Integer.toString(11));
		 System.out.println(Integer.toString(12));
		 System.out.println(Integer.toString(13));
		 System.out.println(Integer.toString(14));
		 System.out.println(Integer.toString(15));
		 System.out.println(Integer.toString(16));
		 // end A
		 
		 // clone of A
		 System.out.println(Integer.toString(10));
		 System.out.println(Integer.toString(11));
		 System.out.println(Integer.toString(12));
		 System.out.println(Integer.toString(13));
		 System.out.println(Integer.toString(14));
		 System.out.println(Integer.toString(15));
		 
		 for(int i = 0; i < 1; ++i) {
			 // The below shouldnt be a clone of A, because comments dont count
			 // clone of A
			 System.out.println(Integer.toString(10));
			 System.out.println(Integer.toString(11));
			 System.out.println(Integer.toString(12));
			 System.out.println(Integer.toString(13));
			 System.out.println(Integer.toString(14));
		 }
		 
		 // clone of last part of A and } in the for loop
		 System.out.println(Integer.toString(10));
		 System.out.println(Integer.toString(11));
		 System.out.println(Integer.toString(12));
		 System.out.println(Integer.toString(13));
		 System.out.println(Integer.toString(14));
			 System.out.println(Integer.toString(15));
	}
	
	private static void foo() {
		// clone of A in different method.
		// also clone of part of A and }! how 2 deal?
		System.out.println(Integer.toString(10));
		System.out.println(Integer.toString(11));
		System.out.println(Integer.toString(12));
		System.out.println(Integer.toString(13));
		System.out.println(Integer.toString(14));
		System.out.println(Integer.toString(15));
		 System.out.println(Integer.toString(16));
	}
}

// cloned lines in this project: 46