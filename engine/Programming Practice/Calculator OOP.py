"""1. In many ways it would be better if all fractions were maintained in lowest
terms right from the start. Modify the constructor for the Fraction class so that
GCD is used to reduce fractions immediately (code for gcd is in page 37 of
textbook. Notice that this means the __add__ function no longer needs to reduce.
Make the necessary modifications.

2. Implement the remaining simple arithmetic operators (__sub__, __mul__, and
__truediv__)."""



# gcd function
def gcd(m, n):
    while m % n != 0:
        old_m = m
        old_n = n
        
        m = old_n
        n = old_m % old_n
    return n

# Fraction class
# Implements: addition and equality
# To do: multiplication, division, subtraction and comparison operators (< , >)
    
class Fraction:
    def __init__(self, top, bottom):
        self.num = top
        self.den = bottom
        common = gcd(self.num, self.den)
        self.num //= common
        self.den //= common
        
    def __str__(self):
        return str(self.num) + "/" + str(self.den)
    
    def show(self):
        print(self.num, "/", self.den, sep = "")    #default value for sep is " "
        
    def __add__(self, other_fraction):      #\ is used to make the code continue in next line, no characters must follow it
        new_num = self.num * other_fraction.den + \
                  self.den * other_fraction.num     
        new_den = self.den * other_fraction.den
        return Fraction(new_num, new_den)

    def __sub__(self, other_fraction):
        new_num = self.num * other_fraction.den - \
                  self.den * other_fraction.num     
        new_den = self.den * other_fraction.den
        return Fraction(new_num, new_den)

    def __mul__(self, other_fraction):
        new_num = self.num * other_fraction.num  
        new_den = self.den * other_fraction.den
        return Fraction(new_num, new_den)
    
    def __truediv__(self, other_fraction):
        new_num = self.num * other_fraction.den  
        new_den = self.den * other_fraction.num
        return Fraction(new_num, new_den)

    def __eq__(self, other):
        first_num = self.num * other.den
        second_num = other.num * self.den
        return first_num == second_num
    
x = Fraction(4, 2)
y = Fraction(2, 3)
print(x + y)
print(x - y)
print(x * y)
print(x / y)
print(x == y)
