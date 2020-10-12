import java.util.Scanner;

public class PalindromeString {
    public static void main(String[] args) {
        //alternatively, you can use a character array
        String word = "", rev = "";
        Scanner ent = new Scanner(System.in);
        word = ent.nextLine();
        for (int i = 0; i < word.length(); i++){
            rev = word.charAt(i) + rev;    
            //if rev and word are character arrays, use rev[rev.length() - 1] = word[i]    
        }
        //NOTE:
        //== tests for reference equality (whether they are the same object).
        //.equals() tests for value equality (whether they are logically "equal").
        if (word.equals(rev)){
            System.out.println(word + " is a palindrome.");
        }

    }    
}
