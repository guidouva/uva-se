
public class CCMain {
	
	static int seq(int j, int i) {
		return j + i;
	}
	
	public static void main(String[] args) {
		seq(1,2);
	}

	static void theif(int j, int i) {
		if(j == i) {
			seq(j,i);
		}
	}
	
	static int ifelse(int j, int i) {
		if(j == i) {
			return seq(j,i);
		} else {
			return seq(j,i);
		}
	}
	
	static int ifelseif(int j, int i) {
		if(j == i) {
			return seq(j,i);
		} else if(j < i) {
			return seq(j,i);
		}
		return seq(j,i);
	}
	
	static int ifelseifelse(int j, int i) {
		if(j == i) {
			return seq(j,i);
		} else if(j < i) {
			return seq(j,i);
		} else {
			return seq(j,i);
		}
	}
	
	static int ifand(int j, int i) {
		if(j == i && i == 1) {
			return seq(j,i);
		}
		return seq(j,i);
	}
	
	static int ifor(int j, int i) {
		if(j == i || i == 1) {
			return seq(j,i);
		}
		return seq(j,i);
	}
	
	static int ifandor(int j, int i) {
		if((j == i && i == 1) || i == 2) {
			return seq(j,i);
		}
		return seq(j,i);
	}
	
	static int iforand(int j, int i) {
		if((j == i || i == 1) && i == 2) {
			return seq(j,i);
		}
		return seq(j,i);
	}
	
	static int nestedif(int j, int i) {
		if(j == i) {
			if(i == 1) {
				return seq(j,i);
			}
		}
		return seq(j,i);
	}
	
	static void switch1(int j, int i) {
		switch(j) {
		case 1:
			seq(j,i);
			break;
		}
	}
	
	static void switch1default(int j, int i) {
		switch(j) {
		case 1:
			seq(j,i);
			break;
		default:
			seq(j,i);
		}
	}
	
	static void switch2(int j, int i) {
		switch(j) {
		case 1:
			seq(j,i);
			break;
		case 2:
			seq(j,i);
			break;
		}
	}
	
	static void switch2nobreak(int j, int i) {
		switch(j) {
		case 1:
			seq(j,i);
		case 2:
			seq(j,i);
			break;
		}
	}
	
	static void switch2default(int j, int i) {
		switch(j) {
		case 1:
			seq(j,i);
			break;
		case 2:
			seq(j,i);
			break;
		default:
			seq(j,i);
		}
	}
	
	static void nestedswitch(int j, int i) {
		switch(j) {
		case 1:
			seq(j,i);
			switch(i){
			case 2:
				seq(j,i);
				break;
			}
			break;
		}
	}
	
	static int cond(int j, int i) {
		return (j == i) ? seq(j,i) : seq(i,j);
	}
	
	static int condand(int j, int i) {
		return (j == i && i == 1) ? seq(j,i) : seq(i,j);
	}
	
	static int condor(int j, int i) {
		return (j == i || i == 1) ? seq(j,i) : seq(i,j);
	}
	
	static int condandor(int j, int i) {
		return ((j == i && i == 1) || j < 10) ? seq(j,i) : seq(i,j);
	}
	
	static int condorand(int j, int i) {
		return ((j == i || i == 1) && j < 10) ? seq(j,i) : seq(i,j);
	}
	
	static int nestedcond(int j, int i) {
		return (j == i) ? (i == 1 ? seq(j,i) : seq(i,j)) : seq(i,j);
	}
	
	static void forin(int j, int i) {
		int[] k = { 1, 2, 3, 4 };
		for(int l : k) {
			seq(j, l);
		}
	}
	
	static void simplewhile(int i, int j) {
		int k = i;
		while(k < j) {
			seq(i, j);
		}
	}
	
	static void whileand(int j, int i) {
		int k = i;
		while(k < j && k < i) {
			seq(i, j);
		}
	}
	
	static void whileor(int j, int i) {
		int k = i;
		while(k < j || k < i) {
			seq(i, j);
		}
	}
	
	static void whileandor(int j, int i) {
		int k = i;
		while((j == i && k < j) || k < i) {
			seq(i, j);
		}
	}
	
	static void whileorand(int j, int i) {
		int k = i;
		while((j == i || k < j) && k < i) {
			seq(i, j);
		}
	}
	
	static void nestedwhile(int j, int i) {
		int k = i;
		while(j == i) {
			while(k > 0) {
				seq(i, j);
			}
		}
	}
	
	static void simpledo(int i, int j) {
		int k = i;
		do {
			seq(i, j);
		} while(k < j);
	}
	
	static void doand(int j, int i) {
		int k = i;
		do {
			seq(i, j);
		} while(k < j && k < i); 
	}
	
	static void door(int j, int i) {
		int k = i;
		do {
			seq(i, j);
		} while(k < j || k < i);
	}
	
	static void doandor(int j, int i) {
		int k = i;
		do {
			seq(i, j);
		} while((j == i && k < j) || k < i);
	}
	
	static void doorand(int j, int i) {
		int k = i;
		do {
			seq(i, j);
		} while((j == i || k < j) && k < i);
	}
	
	static void nesteddo(int j, int i) {
		int k = i;
		do {
			do {
				seq(i, j);
			}while(k > 0);
		} while(j == i);
	}

	// try catch finally
	static void trycatch(int j, int i) {
		try {
			j = i;
		} catch(Exception e) {
			j = 1;
		}
	}
	
	static void tryfinally(int j, int i) {
		try {
			j = i;
		} finally {
			j = 1;
		}
	}
	
	static void trycatchfinally(int j, int i) {
		try {
			j = i;
		} catch(Exception e) {
			j = 1;
		} finally {
			j = 1;
		}
	}
	
	static void trycatchcatch(int j, int i) {
		try {
			j = i;
		} catch(RuntimeException e) {
			j = 1;
		} catch(Exception e) {
			j = 1;
		}
	}
	
	static void trycatchcatchfinally(int j, int i) {
		try {
			j = i;
		} catch(RuntimeException e) {
			j = 1;
		} catch(Exception e) {
			j = 1;
		} finally {
			j = 1;
		}
	}
	
	// for
	static void unconditionalfor(int j, int i) {
		for(int k = 0;;k=k+1) {
			j = i;
		}
	}
	
	static void simplefor(int j, int i) {
		for(int k = 0; k < 10; k=k+1) {
			j = i;
		}
	}
	
	static void forand(int j, int i) {
		for(int k = 0; k < 10 && k >= 0; k=k+1) {
			j = i;
		}
	}
	
	static void foror(int j, int i) {
		for(int k = 0; k < 10 || k >= 0; k=k+1) {
			j = i;
		}
	}
	
	static void forandor(int j, int i) {
		for(int k = 0; (k < 10 && j < 1) || k >= 0; k=k+1) {
			j = i;
		}
	}
	
	static void fororand(int j, int i) {
		for(int k = 0; (k < 10 || j < 1) && k >= 0; k=k+1) {
			j = i;
		}
	}
	
	static void nestedfor(int j, int i) {
		for(int k = 0; k < 10; ++k) {
			for(int l = k; l < j; ++l) {
				seq(i, j);
			}
		}
	}
	
	static void simpleassert(int j, int i) {
		assert(j==i);
	}
	
	static void assertand(int j, int i) {
		assert(j==i && i == 1);
	}
	
	static void assertor(int j, int i) {
		assert(j==i || i == 1);
	}
	
	static void assertandor(int j, int i) {
		assert((j==i && j == 2) || i == 1);
	}
	
	static void assertorand(int j, int i) {
		assert((j==i || j == 2) && i == 1);
	}
	
}
