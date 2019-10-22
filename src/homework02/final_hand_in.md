# Crypto Homework 2 ~ Louis Merlin

## Exercise 1 ~ Order!


```python
# Get variable from parameters file
import utils
params = utils.get_parameters()
```


```python
P = params.Q1_P
```

We have to create the ring of order $P^2$.


```python
ring = IntegerModRing(P ** 2)
```

We find the order $r$ because it is the first non-trivial odd divisor of $P-1$


```python
order = divisors(P-1)[2]

print order
```

    872923


We find the generator of the ring by using the sage method `unit_gens()`


```python
generator = ring.unit_gens()[0]

print generator
```

    5


Now, we find the smallest element of the ring with order $r$. For this we use the fact that this element will be of the form $generator^{i\times P\times(P-1) / order}$, and so we iterate over the $i$s.


```python
# We initiate element to be the biggest number of the ring
element = ring(P ** 2 - 1)
# We will keep the iterative value in gen
gen = ring(1)
mult= generator ** (P * (P - 1) / order)

for i in range(order - 1):
    gen *= mult
    if gen < element:
        element = gen

print element
```

    196925475333199924766685469196508098247094963247954604416185661491801815869078849572926623556083375328539213160952105528828328363989823983634589929591429918641211373


Let's check that $element^{order}\equiv 1 (mod P^2)$


```python
print Integer(element).powermod(order, 65055157034198167228618392426685291748435376135976788685076259415650046232071807945127 ** 2)
```

    1


## Exercise 2 ~ The Adventures of the Crypto-Apprentice: Generalized Vernam Cipher With Key Expansion


```python
# Get variable from parameters file
import utils
params = utils.get_parameters()
```


```python
c2 = params.c2
```

### The Fellowship of the String

UTF-16BE adds `\x00` (NULL) between every ASCII character.

This means that one out of every two bytes in the ciphertext is the "null" character (`00000000` in binary) XORed with the cipherkey.

This means that one of every two bytes **is** the cipherkey.


```python
c2_bin = bin(int(c2, 16))[2:]
```

Le's get every possible prime value that respect the exercise statement :


```python
possible_primes = [
    p for p in range(len(c2) / 2 * 4)
        if is_prime(p) and (p - 1) % 16 == 0
]
```


```python
print len(possible_primes)
```

    259


### The Two Values

Now, for every (prime, a) pair, let's incrementaly compare the keys they generate with what we know from the key (thanks to the key leak in the ciphertext) :


```python
# key_bit computes the bit at index (i, j) for prime p and value a
def key_bit(p, a, j, i=0):
    return mod(mod(((8 * i + j + 1) * a), p), 2)
```


```python
# verify_key verifies the key for a given byte i
def verify_key(p, a, i=0):
    j = 0
    while str(key_bit(p, a, j, i)) == c2_bin[j+8*i] and j < 8:
        j += 1
    if j >= 8:
        return True
```


```python
# filter_by_comparing_with_byte calls verify_key for every (p, a) pair in the global list possible_pairs
def filter_by_comparing_with_byte(i):
    global possible_pairs
    poss = []
    c = c2_bin[0:(i+1)*8]
    for (p, a) in possible_pairs:
        if verify_key(p, a, i):
            poss.append((p, a))
    possible_pairs = poss
```


```python
possible_pairs = []

# Add all pairs (p, a) of (prime, a value) that satisfy the first byte
for p in possible_primes:
    for a in range(0, p):
        if verify_key(p, a):
            possible_pairs.append((p, a))

# Filter possible_pairs until there is only one possible value left
j = 2
while len(possible_pairs) > 1:
    j += 2
    filter_by_comparing_with_byte(j)
```

### The Return of the Key


```python
# decode_binary_string will decode a binary string using a given encoding [FOUND ON STACKOVERFLOW]
def decode_binary_string(s, encoding='UTF-8'):
    byte_string = ''.join(chr(int(s[i*8:i*8+8],2)) for i in range(len(s)//8))
    return byte_string.decode(encoding)
```


```python
# key_builder will generate a key of length l for parameters (p, a)
def key_builder(p, a, l):
    bit_list = [mod(mod(((8 * i + j + 1) * a), p), 2) for i in range((l // 8) + 1) for j in range(8)]
    bit_string = "".join([str(b) for b in bit_list])
    return bit_string
```


```python
# (p, a) is the only remaining pair
(p, a) = possible_pairs[0]

ciphertext = c2_bin

key = key_builder(p, a, len(ciphertext))

binary_plaintext = []

# We xor the ciphertext with the key to get the plaintext
for i in range(len(ciphertext)):
    binary_plaintext.append(str(int(ciphertext[i]) ^^ int(key[i])))

# we decode the encoded binary string
plaintext = decode_binary_string(''.join(binary_plaintext), 'UTF-16BE')

# LOTR <3
print plaintext
```

    Much that once was is lost, for none now live who remember it. It began with the forging of the Great Rings. Three were given to the Elves, immortal, wisest and fairest of all beings. Seven to the Dwarf-Lords, great miners and craftsmen of the mountain halls. And nine, nine rings were gifted to the race of Men, who above all else desire power. For within these rings was bound the strength and the will to govern each race. But they were all of them deceived, for another ring was made. Deep in the land of Clasp, in the Fires of Mount Turfed, the Dark Lord Sauron forged a master ring, and into this ring he poured his cruelty, his malice and his will to dominate all life. One ring to rule them all. One by one, the free lands of Rhomboid fell to the power of the Ring, but there were some who resisted. A last alliance of men and elves marched against the armies of Clasp, and on the very slopes of Mount Turfed, they fought for the freedom of Rhomboid. Victory was near, but the power of the ring could not be undone. It was in this moment, when all hope had faded, that Isildur, son of the king, took up his father's sword. Sauron, enemy of the free peoples of Rhomboid, was defeated. The Ring passed to Isildur, who had this one chance to destroy evil forever, but the hearts of men are easily corrupted. And the ring of power has a will of its own. It betrayed Isildur, to his death. And some things that should not have been forgotten were lost. History became legend. Legend became myth. And for two and a half thousand years, the ring passed out of all knowledge. Until, when chance came, it ensnared another bearer. It came to the creature Gollum, who took it deep into the tunnels of the Misty Mountains. And there it consumed him. The ring gave to Gollum unnatural long life. For five hundred years it poisoned his mind, and in the gloom of Gollum's cave, it waited. Darkness crept back into the forests of the world. Rumor grew of a shadow in the East, whispers of a nameless fear, and the Ring of Power perceived its time had come. It abandoned Gollum, but then something happened that the Ring did not intend. It was picked up by the most unlikely creature imaginable: a hobbit, Bilbo Baggins, of the Farting. For the time will soon come when hobbits will shape the fortunes of all.


## Exercise 3 ~ The Hill Cipher


```python
# Get variable from parameters file
import utils
params = utils.get_parameters()
```


```python
S3 = params.S3
```


```python
# Hill encoding for our 27-letter alphabet
def hill_enc(a):
    e = []
    for c in a:
        if c == ' ':
            e.append(ZZ(0))
        else:
            e.append(ZZ(ord(c) - 96))
    return e
```


```python
# Hill decoding for out 27-letter alphabet
def hill_dec(a):
    f = ''
    for c in a:
        if c == 0:
            f += ' '
        else:
            f += chr(int(c) + 96)
    return f
```


```python
# Number of rows and columns in S3
n = 13

# We get the columns from the parameter string
S3_columns = [S3[i * n:(i + 1) * n] for i in range(n)]

# We use Hill Encoding on S3 and c3
S3_encoded = [hill_enc(r) for r in S3_columns]
c3_encoded = hill_enc(params.c3)

# We create sage matrices in Z_27 with S3 and c3
S3_matrix = Matrix(ZZ.quo(27*ZZ), S3_encoded)
c3_matrix = Matrix(ZZ.quo(27*ZZ), [[v] for v in c3_encoded])
```


```python
p3_encoded = []

# For each piece of c3 of length 13
for i in range(7):
    c3_column = c3_matrix[i * n:(i + 1) * n]
    # We solve the matrix equation S3 * m = c3 for m
    m = S3_matrix \ c3_column
    # And we add the result to the final array
    p3_encoded += m

# We use Hill Decoding to find the final message
decoded_message = hill_dec([c[0] for c in p3_encoded])
print decoded_message
```

    a magic sentence with random words edges and chowing whose length is a multiple of thirteen


## Exercise 4 ~ Bat-Crypt, Diffie-Helman Over The Linear Group


```python
import utils
params = utils.get_parameters()
```


```python
p = params.Q4_p
generator = params.Q4_generator
public_key = params.Q4_public_key
ciphertext = params.Q4_ciphertext
```


```python
# We create the $Z_p$ ring
ring = IntegerModRing(p)
```

### What we know

- $S_a$ : random in $Z_{p-1}$
- $r$ : $generator^{S_a}$
- $s$ : $PK^{S_a}$
- $c$ : $(r, sm)$


```python
r = Matrix(ZZ.quo(p * ZZ), ciphertext[0])
C = Matrix(ZZ.quo(p * ZZ), ciphertext[1])
```


```python
gen = Matrix(ZZ.quo(p * ZZ), generator)
```


```python
PK = Matrix(ZZ.quo(p * ZZ), public_key)
```

### What we can see

$C=sm=PK^{S_a}m=\begin{pmatrix}1 & x \\ 0 & 1\end{pmatrix}\begin{pmatrix}a & b \\ c & d\end{pmatrix}=\begin{pmatrix}a+xc & b+xd \\ c & d\end{pmatrix}$

This means we know $c$ and $d$ !

In this formula, we have $x=PK_{0,1}^{S_a}$


```python
c = C[1][0].lift()
d = C[1][1].lift()
```

### Oh no batman, what have you done ?

It looks like $r = g^{S_a} = \begin{pmatrix}1 & g_{0,1}\\ 0 & 1\end{pmatrix}^{S_a} = \begin{pmatrix}1 & S_a\times g_{0,1} \\ 0 & 1\end{pmatrix}$

This means we can more than easily compute $S_a$, to the great shock of both Batman and Alfred :


```python
Sa = ring(r[0, 1]) / ring(gen[0, 1]) 
```

Now that we know $S_a$, Batman cannot hide his secrets from us anymore.


```python
x = PK[0, 1] * Sa
```


```python
a = ring(C[0, 0].lift() - x * c)
b = ring(C[0, 1].lift() - x * d)
```


```python
print a
print b
print c
print d
```

    72183823406034509235986586944502383596377699130816560539868646933200483877969
    95718758738497920252346111702638870293528859908622092482544148559048233181545
    64967421248684864379889327593325353110390216977711986294038512996956299557015
    7339505830888704565540323351330274914845452103920341534257862753661522891484


## Exercise 5 ~ Polynomial Encryption Scheme


```python
import random
import utils
params = utils.get_parameters()
```


```python
# p: a large public prime
p = Integer(params.Q5_p)

# y: the private key for part 2
y = Integer(params.Q5b_y)

# z: the random number for encryption in part 1
z = Integer(params.Q5a_z)
```


```python
ring = IntegerModRing(p)
Ring.<x> = PolynomialRing(ring)
```


```python
# P: a public reducible polynomial of degree k > 0
# Used for modulation
P = Ring(params.Q5_P)

# G: a public reducible polynomial of degree k > 0
# Used as a base
G = Ring(params.Q5_G)

# Y: a public reducible polynomial of degree k > 0
# Used as the public key in part 1
Y = Ring(params.Q5a_Y)

# M: a public reducible polynomial of degree k > 0
# Used as encrypted data in part 1
M = Ring(params.Q5a_M)

# Z: a reducible polynomial of degree k > 0
# Z=G^{z_2}, used in part 2
Z = Ring(params.Q5b_Z)

# V: a reducible polynomial of degree k > 0
# Encrypted message to decrypt in part 2
V = Ring(params.Q5b_V)
```

We build `QRing`, the ring of polynomials modulo $P$.


```python
QRing.<x> = Ring.quotient(P)
```

### 1. Encrypt $M(x)$ for the public key $Y(x)$ by using the integer $z$


```python
# Encryption algorithm
def encrypt(G, Y, M, z):
    # 1: Sample z from { 0, 1, ..., n-1 }
    # 2: Z(x) <- (G(x))^z mod P(x)
    Z = QRing(G) ** z
    # 3: V(x) <- M(x) * (Y(x))^z mod P(x)
    V = QRing(M) * (QRing(Y) ** z)
    # 4: return (Z(x), V(x))
    return (Z, V)
```


```python
a_Z, a_V = encrypt(G, Y, M, z)
```


```python
print a_Z
print a_V
```

    225908100365443684627306957924584923*x^16 + 38288812065621670387851925324921584*x^15 + 220746096145500473829711170083446554*x^14 + 64488510482324258144802004375227464*x^13 + 112687822123130875554237550668201034*x^12 + 476728348298306181635479343932709082*x^11 + 286569228701237719156121883478877783*x^10 + 144651844568979744198085562118925311*x^9 + 162735568017991734164720037662573479*x^8 + 538820669586962493187829763983808048*x^7 + 72131441992823027199706500722730450*x^6 + 82338937875812413136638724593009818*x^5 + 644214900178284851076679780873178607*x^4 + 181842784107414246180627179777111307*x^3 + 572083026649562563683756466345767486*x^2 + 277769076800908100739374495022601031*x + 485557968317910457471890026994886642
    443766152124804919445034718980552468*x^16 + 646427559877355027502943381127693326*x^15 + 323696457239519122274690270026981104*x^14 + 366804946919289785422697218673359581*x^13 + 291616180259097720193194897959488231*x^12 + 23660637528384932031137307997328128*x^11 + 117880776627751316188065802286636397*x^10 + 397193539626484002656879811963756721*x^9 + 635612693730531465019670942589686066*x^8 + 510107940557188058826394367687916779*x^7 + 346854352477020786635863653899987833*x^6 + 469822117187279317457750250724247140*x^5 + 519076906739124041154798310152505090*x^4 + 232499798263233639265666373676389578*x^3 + 478024746224901568951894998074503238*x^2 + 258156594141229036778481241492426844*x + 140805839567831411403988310203816177


### 2. Decrypt $Z(x)$, $V(x)$ with the secret key $y$

$A(x)=Z^y(x)=G^{zy}(x)=Y^z(x)$

$V(x)\times H^{-1}(x)=M(x)$


```python
# Decryption algorithm
def decrypt(Z, V, y):
    # 1: A(x) <- (Z(x))^y mod P(x)
    A = QRing(Z) ** y
    # 2: B(x) <- (A(x))^-1 mod P(x)
    B = QRing(A) ** -1
    # 3: M(x) <- V(x) * B(x) mod P(x)
    M = V * B
    # 4: return M(x)
    return M
```


```python
b_M = decrypt(Z, V, y)
```


```python
print b_M
```

    503872880176649919187500647298316272*x^16 + 448108830212726884195635070845879966*x^15 + 40142176636285399918280438448300632*x^14 + 545235221455774785336133991069896063*x^13 + 624103169448316473411194704127776080*x^12 + 422957851022610057192913669426144858*x^11 + 539858395160763652194579794579767763*x^10 + 405191785295021611611097957015438901*x^9 + 325546388948605779361074857529948791*x^8 + 661733762726954561371271906315852834*x^7 + 497710875828618858689680214284131868*x^6 + 283508675643580136908811425697299200*x^5 + 167853340820944549302371557532309047*x^4 + 445579911746622424641985456428136658*x^3 + 337126671827574694981362335395032279*x^2 + 157940171676356532805653092288576637*x + 654765336382858625101155794138000514

