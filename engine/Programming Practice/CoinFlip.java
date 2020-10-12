import java.util.LinkedList;

public class CoinFlip {
    public static void main(String[] args) {
        LinkedList<Boolean> flip = new java.util.LinkedList<Boolean>();
        flip.add(true);
        flip.add(true);
        flip.add(false);
        flip.add(true);
        flip.add(true);
        for (int i = 0; i < flip.size(); i++){
            System.out.println(flip.get(i) == true);
        }
        System.out.println();
    }
}
