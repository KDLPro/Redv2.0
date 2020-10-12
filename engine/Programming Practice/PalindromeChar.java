import java.util.Scanner;

public class PalindromeChar {
    public static void main(String[] args) {
        char[] word = {'a', 'b', 'b', 'a'};
        char[] rev = new char[word.length];
        Scanner ent = new Scanner(System.in);
        for (int i = 0; i < word.length; i++){
            rev[word.length - i - 1] = word[i];  
        }
        int equals = 0;
        String words = "";
        for (int i = 0; i < word.length; i++){
            words += word[i];
            if (word[i] == rev[i]){
                equals++;
            }
        }
        if (equals == word.length){
            System.out.println(words + " is a palindrome.");
        }
    }    
}
