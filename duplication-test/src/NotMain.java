
public class NotMain {

	public static void bar() {
		// not clone of A
		System.out.println(Integer.toString(11));
		 System.out.println(Integer.toString(12));
		 System.out.println(Integer.toString(13));
		 System.out.println(Integer.toString(14));
			 System.out.println(Integer.toString(15));
			 
		// clone of A in different file.
		// also clone of part of A and }! how 2 deal?
		// pick the largest?
		System.out.println(Integer.toString(10));
		System.out.println(Integer.toString(11));
		System.out.println(Integer.toString(12));
		System.out.println(Integer.toString(13));
		System.out.println(Integer.toString(14));
		System.out.println(Integer.toString(15));
	}

}
