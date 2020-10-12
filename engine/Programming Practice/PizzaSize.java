import java.util.Scanner;
public class PizzaSize {
    public static void main(String[] args) {
        Scanner scan = new Scanner(System.in);
        System.out.println("Size of your pizza in inches? ");
        int size = scan.nextInt();
        System.out.println((size / 2) * (size / 2) * Math.PI);
        System.out.println();

        System.out.println("Input total area: ");
        double area = scan.nextDouble();
        System.out.println("Input pizza price: ");
        int price = scan.nextInt();
        System.out.println(area/price);
    }
}
