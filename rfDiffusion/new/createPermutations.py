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
# nums = [ "G1143-G1150", "G1222-12229" , "G1305-G1322"]
#allowable_pairs = [ ["A131-139","A153-159" ], [ "A131-139", "A183-194" ], [ "A131-139", "A226-230" ], [ "A97-100", "A183-194" ], [ "A97-100", "A153-159" ], [ "A97-100", "A226-230" ], [ "A226-230", "A183-194" ], [ "A226-230", "A153-159" ], [ "A226-230", "A131-139" ], [ "A153-159", "A183-194" ], [ "A153-159", "A131-139" ], [ "A183-194", "A131-139" ], [ "A183-194", "A153-159" ], [ "A183-194", "A97-100" ] ] 

# Contigs (4TVP)
# 1: A87-92
# 2: A234-240
# 3: A527-529
# 4: A617-633
# B: B1-1618

# nums = [ "A87-92","A234-240","A527-529","A617-633"]

# # Contigs (5FYK)
# # 1: A87-92
# # 2: A238-243
# # 3: A527-529
# # 4: A616-633
# # B: B1-225

# nums = [ "A87-92","A238-243","A527-529","A616-633"]

# # Contigs (CoV-2-RBD rfDiffusion)
# 1: A415-419
# 2: A444-A458
# 3: A485-A507
# B: B19-615 

# nums = [ "A415-419","A444-458","A485-507"]

# # Contigs (CoV-2-RBD rfDiffusion2)
# 1: A344-354
# 2: A368-379
# 3: A398-426
# 4: A433-511
# B: B19-615

# nums = [ "A344-354","A368-379","A398-426", "A433-511"]

# Contigs (1KG0)
# 1: C64-74
# 2: C75-85
# 3: C86-89
# B: B1-63

nums = [ "C64-74","C75-85","C86-89"]
blocker = "B1-63"

# Contigs (769B10)
# 1: A1-12
# 2: A13-30
# 3: B31-33
# 4: B34-38
# B: H39-130

# nums = [ "A1-12","A13-30","B31-33", "B34-38"]
# blocker = "H39-130"

# Contigs (769C2)
# 1: A1-18
# 2: B19-28
# 3: B29-33
# B: X34-117

# nums = [ "A1-18","B19-28","B29-33"]
# blocker = "X34-117"

r = list(allowable_lists(nums))
for i in (r):
#    print(i)
    str = ""
    k=0
    for j in (i):
        if (k == 0):
            str = ("2-20/%s" % (j))
            k+=1
        else:
            str = ("%s/2-40/%s" % (str,j))
    print(f"[{str}/2-20/0 {blocker}]")
print("Number of combinations: %d" % len(list(r)))

for index,i in enumerate(r):
    print(f"if [ \"$topo\" -eq \"{index+1}\" ]")

    print("   then")

    str = ""
    k=0
    for j in (i):
        if (k == 0):
            str = ("2-20/%s" % (j))
            k+=1
        else:
            str = ("%s/2-40/%s" % (str,j))

    print(f"       contig=\"[{str}/2-20/0 {blocker}]\"")

    print("fi")





