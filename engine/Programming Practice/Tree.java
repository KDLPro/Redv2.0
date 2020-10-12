import java.util.Scanner;

public class Tree {
    public static void main(String[] args) {
        int l;
        Scanner ent = new Scanner(System.in);
        l = ent.nextInt();
        if (l > 2){
            for (int i = l; i > 0; i--){
                for (int j = 0; j < i - 1; j++){
                    System.out.print(" ");
                }
                for (int j = 1; j < (2 * (l - i + 1)); j++){
                    System.out.print("*");
                }
                System.out.println();
            }
            for (int j = 0; j < l - 1; j++){
                System.out.print(" ");
            }
            System.out.println("*");
        }
    }
}
