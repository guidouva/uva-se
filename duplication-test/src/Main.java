public class Main {
	public static void main(String[] args) {
		 // begin A
		 System.out.println(Integer.toString(10));
		 System.out.println(Integer.toString(11));
		 System.out.println(Integer.toString(12));
		 System.out.println(Integer.toString(13));
		 System.out.println(Integer.toString(14));
		 System.out.println(Integer.toString(15));
		 // end A
		 
		 // clone of A
		 System.out.println(Integer.toString(10));
		 System.out.println(Integer.toString(11));
		 System.out.println(Integer.toString(12));
		 System.out.println(Integer.toString(13));
		 System.out.println(Integer.toString(14));
		 System.out.println(Integer.toString(15));
		 
		 for(int i = 0; i < 1; ++i) {
			 // clone of "clone of A" because comment?
			 // so pick the 7 lines one, and not 6 lines
			 // clone of A
			 System.out.println(Integer.toString(10));
			 System.out.println(Integer.toString(11));
			 System.out.println(Integer.toString(12));
			 System.out.println(Integer.toString(13));
			 System.out.println(Integer.toString(14));
			 System.out.println(Integer.toString(15));
		 }
		 
		 // clone of last part of A and } in the for loop
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
	}
}

// clones: 