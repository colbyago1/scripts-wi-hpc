from itertools import permutations


def get_pairs(lst):
    pairs = []
    for i in range(len(lst)-1):
        pairs.append((lst[i], lst[i+1]))
    return pairs

def allowable_lists(nums, pairs=0):
    # create a set of all possible permutations of the numbers
    all_lists = set(permutations(nums))
    if (not pairs):
        return(all_lists)
    
    for lst in all_lists.copy():
#        print("LIST: %s %d" % (list(lst),len(list(all_lists))))
        for pair in get_pairs(lst):
#            print("PAIR: %s" % list(pair))
            if (list(pair) not in pairs):
#                print("REMOVE IT")
                all_lists.remove(lst)
                break

        
    return all_lists

#nums = [1, 2, 3, 4, 5]
#allowable_pairs = [[1, 2], [2, 3], [3, 4], [4, 5], [5, 1]]

#nums = [ "I411-420", "I321-334" , "I293-303", "I131-158" ]
nums = [ "G1143-G1150", "G1222-12229" , "G1305-G1322"]
#allowable_pairs = [ ["A131-139","A153-159" ], [ "A131-139", "A183-194" ], [ "A131-139", "A226-230" ], [ "A97-100", "A183-194" ], [ "A97-100", "A153-159" ], [ "A97-100", "A226-230" ], [ "A226-230", "A183-194" ], [ "A226-230", "A153-159" ], [ "A226-230", "A131-139" ], [ "A153-159", "A183-194" ], [ "A153-159", "A131-139" ], [ "A183-194", "A131-139" ], [ "A183-194", "A153-159" ], [ "A183-194", "A97-100" ] ] 

r = list(allowable_lists(nums))
for i in (r):
#    print(i)
    str = ""
    k=0
    for j in (i):
        if (k == 0):
            str = ("2-30/%s" % (j))
            k+=1
        else:
            str = ("%s/6-30/%s" % (str,j))
    print("[%s/2-30/0 C1-22]" % str)
print("Number of combinations: %d" % len(list(r)))






