public class TokenCount {

    
    public static void main(String[] args){
    }

    java.lang.String exp;
    int tokens = 0;

    public TokenCount(java.lang.String string) {
        setExp(string);
    }

    public void setExp(java.lang.String string) {
        this.exp = string;
    }

    public java.lang.String getExp() {
        return this.exp;
    }

    public int numTokens(){
        this.tokens = exp.length();
        for (int i = 0; i < exp.length(); i++){
            switch(exp.charAt(i)){
                case ' ':
                    this.tokens--;
            }
        }
        return this.tokens;
    }

}
