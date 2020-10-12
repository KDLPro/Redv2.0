#include <iostream>
using namespace std;

int main(){
    cout << "Input two numbers to compare:" << endl;
    int a, b;
    cout << "1st Number: ";
    cin >> a;
    cout << "2nd Number: ";
    cin >> b;

    if (a < b){
        cout << a << " is less than " << b <<".";
    }else if (a > b){
        cout << a << " is greater than " << b << ".";
    }else{
        cout << a << " is equal to " << b << ".";
    }

    return 0;
}
