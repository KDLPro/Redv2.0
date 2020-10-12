import java.util.*;

public class ExpEvaluate {
    private Stack exp = new Stack();
    private boolean lastIntPush = false;  //if last element pushed in stack is int
    private char[] num = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
    private int popped;

    public boolean checkNum(int number){
        for (int i = 0; i < num.length; i++){
            if (number == num[i]){
                return true;
            }
        }
        return false;
    }

    public ExpEvaluate(String prob){
        for (int i = 0; i < prob.length(); i++){
            if (prob.charAt(i) == '('){
                exp.push(prob.charAt(i));
                lastIntPush = false;        //to reset status of lastIntPush as false
            } else if (checkNum(prob.charAt(i)) && lastIntPush){
                exp.push(Integer.parseInt(String.valueOf(prob.charAt(i))));
                lastIntPush = true;        //to set status of lastIntPush as false
            } else if (checkNum(prob.charAt(i)) && !(lastIntPush)){
                popped = Integer.parseInt(String.valueOf(prob.charAt(i)));
                exp.push(Integer.parseInt(String.valueOf(prob.charAt(i))));
                lastIntPush = true;        //to set status of lastIntPush as false
            } else if (prob.charAt(i) == '+'){
                exp.push(prob.charAt(i));
                lastIntPush = false;        //to reset status of lastIntPush as false
            } else if (prob.charAt(i) == '-'){
                exp.push(prob.charAt(i));
                lastIntPush = false;        //to reset status of lastIntPush as false
            } else if (prob.charAt(i) == '*'){
                exp.push(prob.charAt(i));
                lastIntPush = false;        //to reset status of lastIntPush as false
            } else if (prob.charAt(i) == '/'){
                exp.push(prob.charAt(i));
                lastIntPush = false;        //to reset status of lastIntPush as false
            } 
        }
        System.out.println(solveExp());
    }

    public char stackToChar(Object e){
        if (e.getClass() == String.class){
            return String.valueOf(e).charAt(0);
        }
        return (char) e;
    }

    public int solveExp(){
        int ans = 0;
        char current = stackToChar(exp.pop());
        while (current != '('){
            if (checkNum(current)){
                ans = current;
            } else if (current == '+'){
                current = stackToChar(exp.pop());
                ans += current;
            } else if (current == '-'){
                current = stackToChar(exp.pop());
                ans -= current;
            } else if (current == '*'){
                current = stackToChar(exp.pop());
                ans *= current;
            } else if (current == '/'){
                current = stackToChar(exp.pop());
                ans /= current;
            }
        }
        return ans;
    }



    public static void main(String[] args) {
        ExpEvaluate solve = new ExpEvaluate("(5+6)");
    }
}
