#!/usr/bin/env python2.7

'''

Bigchar layout:

    A B
    C D

'''

def char_to_asm(xs):
    return '.db ' + ', '.join('0b' + bin(x)[2:].zfill(5) for x in xs)

data = open("font.txt", "r").read().rstrip()

bigchars = []

for i, lines in enumerate(data.split('\n\n')):
    lines = lines.split('\n')[2:]
    assert len(lines) == 20

    lines = lines[1:-3]
    assert len(lines) == 16

    a = []
    b = []
    c = []
    d = []

    for line in lines[:8]:
        a.append(int(line[:5], 2))
        b.append(int(line[5:], 2))

    for line in lines[8:]:
        c.append(int(line[:5], 2))
        d.append(int(line[5:], 2))

    bigchars.append((a, b, c, d))

'''
for i, (a, b, c, d) in enumerate(bigchars):
    print 'Bigchar_%d:' % i
    print char_to_asm(a)
    print char_to_asm(b)
    print char_to_asm(c)
    print char_to_asm(d)
    print
'''

'''
a = bigchars[0][0]
b = bigchars[0][1]

# shift a to the left by j cols
j = 0
a_ = [(n << j | m >> (5 - j)) & 0x1F for n, m in zip(a, b)]
'''

def char_shift(a, b, j):
    return [(n << j | m >> (5 - j)) & 0x1F for n, m in zip(a, b)]

empty_bigchar = ([0 for i in xrange(8)],)*4

bigchars.insert(0, empty_bigchar)
bigchars.append(empty_bigchar)

print 'Bigchar_Start:'
print

for i in xrange(0, len(bigchars)-1):
    a1, b1, c1, d1 = bigchars[i]
    a2, b2, c2, d2 = bigchars[i+1]

    # <- a1 <- b1 <- a2 <- b2
    # <- c1 <- d1 <- c2 <- d2

    if i == 0:
        name_1 = 'X'
    else:
        name_1 = str(i-1)

    if i == len(bigchars)-2:
        name_2 = 'X'
    else:
        name_2 = str(i)

    name = name_1 + '_' + name_2

    for j in xrange(0, 5):
        a_ = char_shift(a1, b1, j)
        b_ = char_shift(b1, a2, j)
        c_ = char_shift(c1, d1, j)
        d_ = char_shift(d1, c2, j)

        print 'Bigchar_%s_%d:' % (name, j)
        print char_to_asm(a_)
        print char_to_asm(b_)
        print char_to_asm(c_)
        print char_to_asm(d_)
    for j in xrange(0, 5):
        a_ = char_shift(b1, a2, j)
        b_ = char_shift(a2, b2, j)
        c_ = char_shift(d1, c2, j)
        d_ = char_shift(c2, d2, j)
        print 'Bigchar_%s_%d:' % (name, j+5)
        print char_to_asm(a_)
        print char_to_asm(b_)
        print char_to_asm(c_)
        print char_to_asm(d_)

    print
