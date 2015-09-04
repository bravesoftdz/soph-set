package net.set.game;

import java.util.ArrayList;
import java.util.List;


public class GameLogic {
	static int nCards = 81;
    static List<Integer> logic = new ArrayList<>(nCards);
    // bit masks for low and high bits of the attributes        
    static int mask0 = 85;    //01010101
    static int mask1 = 170;   //10101010
    
    public static byte s1,s2,s3;
	public GameLogic() {
		for (int c = 0; c < 81; c++) {
			int t = c, l = 0;
			for (int i = 27; i != 1; i /= 3) {
				l = (l << 2) + t/i;
	            t = t % i;
			}
		l = (l << 2) + t;
		logic.add(l);
		}
	}

    public static int thirdCardLogic(Integer integer, Integer integer2) {
    	int xor = integer^integer2;
    	int swap = ((xor & mask1) >> 1) | ((xor & mask0) << 1);
    	return (integer&integer2) | (~(integer|integer2) & swap);
    }
    
    public static boolean Set(byte c1, byte c2, byte c3) { //Card Numbers
    	return (int) logic.get(c3) == thirdCardLogic(logic.get(c1),logic.get(c2));
	}

	public static boolean SetExists(Game game) {
		synchronized (game.cardlist) {
			int csize = game.cardlist.size();
			for (int ci = 0; ci < csize; ci++)
				for (int cj = ci + 1; cj < csize; cj++)
					for (int ck = cj + 1; ck < csize; ck++)
						if (Set(game.cardlist.get(ci), game.cardlist.get(cj), game.cardlist.get(ck)))
							return true;
		}
		return false;
	}
	
	public static boolean SetExistsIgnore(Game game, byte c1, byte c2, byte c3) {
		byte a1, a2, a3;
		synchronized (game.cardlist) {
			int csize = game.cardlist.size();
			for (int ci = 0; ci < csize; ci++)
				for (int cj = ci + 1; cj < csize; cj++)
					for (int ck = cj + 1; ck < csize; ck++) {
						a1 = game.cardlist.get(ci);
						a2 = game.cardlist.get(cj);
						a3 = game.cardlist.get(ck);
						if (a1 == c1 || a1 == c2 || a1 == c3)
							continue;
						if (a2 == c1 || a2 == c2 || a2 == c3)
							continue;
						if (a3 == c1 || a3 == c2 || a3 == c3)
							continue;
						if (Set(a1, a2, a3))
							return true;
					}
		}
		return false;
	}
	
	public static boolean getSet(Game game) {
		synchronized (game.cardlist) {
			int csize = game.cardlist.size();
			for (int ci = 0; ci < csize; ci++) {
				for (int cj = ci + 1; cj < csize; cj++) {
					for (int ck = cj + 1; ck < csize; ck++) {
						if (Set(game.cardlist.get(ci), game.cardlist.get(cj), game.cardlist.get(ck))) {
							s1 = (byte) ci;
							s2 = (byte) cj;
							s3 = (byte) ck;
							System.out.print(s1);
							System.out.print(" ");
							System.out.print(s2);
							System.out.print(" ");
							System.out.print(s3);
							System.out.println();
							return true;
						}
					}
				}
			}
		}
		return false;
	}
}

