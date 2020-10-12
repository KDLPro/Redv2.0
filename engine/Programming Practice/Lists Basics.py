thislist = ["apple", "banana", "cherry"]
print(thislist)
print(thislist[-3])
thislist = ["apple", "banana", "cherry", "orange", "kiwi", "melon", "mango"]
print(thislist[2:5])
print(thislist[:4])
print(thislist[2:])
thislist[2] = "lemon"
print(thislist)
for i in thislist:
    print(i)        #print all elements of thislist, one by one
for i in thislist:
    if i != thislist[6]:
        print(i, end = ", ")        #print all elements of thislist, one by one
    else:
        print(i)
if "apple" in thislist:
    print("Yes, apple is in thislist.")
if "cherry" in thislist:
    print("Yes, cherry is in thislist.")
print("There are ", len(thislist), " elements in this list.", sep = "")
