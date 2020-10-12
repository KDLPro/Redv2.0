"""Create a program that accepts a number n and prints the number of
prime numbers between 1 and n (excluding n)."""

n = int(input("Please enter a number: "))
fact = 0            #number of factors
prime = 0           #number of prime numbers
for j in range(2, n):
    for i in range(2, j + 1):
        if (j % i == 0):
            fact += 1
            print(j % i)
    if (fact == 1):
        prime += 1
    print(fact, prime, j)
    fact = 0
print(prime)
    
