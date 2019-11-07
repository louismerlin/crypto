# Crypto Homework 3 ~ Louis Merlin

## Exercise 1 ~ Factoring by orders of elements


```python
# Get variable from parameters file
import utils
params = utils.get_parameters()
```


```python
k = params.Q1_k
x = params.Q1_x
N = params.Q1_N
```

We know that
- $N=p\times q$, with $\frac{p-1}{2}$ prime and $\frac{q-1}{2}$ prime
- $x\in\mathbb{Z}_N^*$
- $k$ is the order of $x$ in either $\mathbb{Z}_p^*$ or $\mathbb{Z}_q^*$

We have to find $p$ and $q$, and put the **smallest** of the two in the answer file.

Let's say that $k$ is the order of $x$ in $\mathbb{Z}_p^*$.

We know that $\varphi(p)=p-1$ because $p$ is prime.

We also know that $k$, being an order of a number in $\mathbb{Z}_p^*$, has to be a factor of $\varphi(p)$.

We also know that $\frac{p-1}{2}$ is prime.

This means that
- $k=2$ or
- $k=p-1$ or
- $k=\frac{k-1}{2}$

We can now very easily find $p$, because $k\neq2$ :


```python
if is_prime(k + 1):
    p = k + 1
else:
    p = k * 2 + 1
```

Now that we have $p$, we can find $q$ :


```python
q = N // p
```

We verify our assertions :


```python
print is_prime(p) and is_prime(q) and p * q == N
```

    True


And we print the smallest of the two


```python
print min(p, q)
```

    14479573000805883152954178569811189316969443659853631273008899



## Exercise 2 ~ 7 deadly residues


```python
# Get variable from parameters file
import utils
params = utils.get_parameters()
```


```python
n = params.Q2_n
factors = params.Q2_factors
elements = params.Q2_elements
```

$p$ is a prime such that $p\equiv1\ (\textrm{mod}\ 7)$.

Let $g$ be the smallest generator of $\mathbb{Z}_p^*$.

For $x\in\mathbb{Z}_p^*$, $(\cdot)_p$ is defind such that $(x)_p$ is the value from $\mathbb{Z}_7$ that satisfies:

$$
g^{(x)_p}\cdot z^7\equiv x\ (\textrm{mod}\ p)\textrm{ for some }z\in\mathbb{Z}_p^*\textrm{.}
$$

For $n=p_1\cdot p_2\cdot \cdots \cdot p_l$ where $p_i\equiv1\ \textrm{mod}\ 7$ for all $i\in[1,l]$, and $x\in\mathbb{Z}_n^*$:

$$
(x)_n=((x)_{p_1}+(x)_{p_2}+\cdots+(x)_{p_l})\ \textrm{mod}\ 7
$$

### Good residue

We can extend the definition of the quadratic residue : an element $x$ is a good residue iff $x^{(p-1)/7}\equiv1\ \textrm{mod}\ p_i$ for every $p_i$ prime factors of $n$.

### Fake residue

Using the definition of the good residue, we can find the value $(x)_p$ such that $\frac{x}{g^{(x)_p}}$ is a good residue, and add the $(x)_p$s to get $(x)_n$ ($g$ is a generator of the ring of integers mod $p$).


```python
def classify(x):
        
    # good residue
    # (x ^ ((p-1)/7) == 1 mod p) for every p in factors
    is_good_residue = True
    for p in factors:
        if power_mod(x, (p - 1) // 7, p) != 1:
            is_good_residue = False
    if is_good_residue:
        return 0
    
    # fake residue
    # same criteria, but x is divided by g^x_p with x_p in range(7)
    x_n = 0
    for p in factors:
        ring = IntegerModRing(p)
        g = ring.unit_gens()[0]
        for x_p in range(7):
            if power_mod(ring(x) / ring(g ** x_p), (p - 1) // 7, p) == 1:
                x_n += x_p
                break
    if mod(x_n, 7) == 0:
        return 1
    
    # non residue
    return 2

result = [classify(x) for x in elements]
print result
```

    [2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]


## Exercise 3 ~ Thunderstuck!


```python
# Get variable from parameters file
import utils
params = utils.get_parameters()
```


```python
transcript = params.Q3_transcript
N = params.Q3_N
```

### Variables:

- Public key $(N, e)$
- $p$ and $q$, RSA primes
- Secret key $s$, a fairly large exponent

### Encryption:

Plain RSA.

### Decryption:

RSA with CRT for more performance (see slide #271).

### Given:

$N$ and some (ciphertext, plaintext) pairs, with some that were not done correctly.

### Errors:

During the computation of $m^d$ in the decryption, voltage spikes caused errors.

### Goal:

Factorize N and give the **larger** prime divisor of N.

### Decryption mechanism

With

$a=(m\ \textrm{mod}\ p)^{s\ \textrm{mod}\ (p-1)}\ \textrm{mod}\ p$

$b=(m\ \textrm{mod}\ q)^{s\ \textrm{mod}\ (q-1)}\ \textrm{mod}\ q$

$y^s\ \textrm{mod}\ pq=ap(p^{-1}\ \textrm{mod}\ q)+bq(q^{-1}\ \textrm{mod}\ p)\ (\textrm{mod}\ pq)$

### Zap

We find the pairs where the ciphertext is present more than once in the dataset (which means that we have a wrong plaintext and the right plaintext) :


```python
dups = set()
for (i, (u, v)) in enumerate(transcript):
    d = [j for (j, (u2, v2)) in enumerate(transcript) if u2 == u]
    if len(d) == 2:
        dups.add((transcript[d[0]][1], transcript[d[1]][1]))
```

### CRT

A theory of what the zap does is that one of the two exponentiations during the decryption is set to 0.

This would mean that the difference between a real plaintext and a wrong plaintext would be divisible by p or q !


```python
# We get the absolute differences beween the plaintexts of the dups list
diffs = [abs(u1 - u2) for (u1, u2) in dups]
```

In order to find p or q, we can now get the gcd of, for example, the first element with every other element. p or q would have to be one of those gcds if the theory is correct.


```python
gcds = [gcd(diffs[0], d) for d in diffs[1:]]

for p in gcds:
    if N // p == N / p and p != 1:
        q = N // p
        if p > q:
            print p
        else:
            print q
        break
```

    9195717468371647099146433968353552538002297448971726285439273707898124547771394001981043862107843557766876090106640968634345125678887337236969767590825217


The theory was correct ! We have found Batman's secret key.


## Exercise 4 ~ Diffie-Hellman Key Exchange Over $\mathbb{Z}_p^*$


```python
# Get variable from parameters file
import utils
params = utils.get_parameters()
```


```python
p = Integer(params.Q4_p)
g = Integer(params.Q4_g)
X = Integer(params.Q4_X)
Y = Integer(params.Q4_Y)
```


```python
group = IntegerModRing(p).unit_group()
```

Because the order of the ring $p - 1$ is not prime, we can get the factors of $p - 1$ :


```python
print factor(group.order())
```

    2 * 532751 * 547817 * 550951 * 579713 * 580409 * 604277 * 612371 * 637529 * 656603 * 661541 * 679597 * 702077 * 710837 * 801421 * 803461 * 810769 * 823619 * 826663 * 865807 * 912773 * 938057 * 942901 * 950233 * 953297 * 978931 * 990281 * 1001797 * 1014649 * 1016599 * 1040483 * 1042961 * 1047491



```python
factors = [u for (u, v) in list(factor(group.order()))]
```

### Pohlig-Hellman

Let's use the [Polhig-Hellman algorithm](https://en.wikipedia.org/wiki/Pohlig%E2%80%93Hellman_algorithm#The_general_algorithm) :


```python
x_mods = []
ring = IntegerModRing(p)

# Step 1
for i, f in enumerate(factors):
    # Substep 1
    g_i = ring(power_mod(g, (p - 1) // f, p))
    # Substep 2
    h_i = ring(power_mod(X, (p - 1) // f, p))
    # Substep 3
    x_mods.append(discrete_log(h_i, g_i, f))
# Step 2
x = crt(x_mods, factors)
```


```python
print Y.powermod(x, p)
```

    163195499106861376244878769783259974190355145685432720176478803699879434189098317339265133664241400195782368205346198430764939174533923102190120123236012806786104714539833763422451317381892


## Exercise 5 ~ The Adventures of the Crypto-Apprentice: Return Of Vernam Cipher


```python
# Get variable from parameters file
import utils
import binascii
params = utils.get_parameters()
```


```python
p = params.Q5_p # the prime number
a = params.Q5_a # a first integer
b = params.Q5_b # a second integer
C = params.Q5_C # the ciphertext
y = params.Q5_y # y-coordinate of [2^{2|M'|}]P
n = params.Q5_n # the order of the elliptic curve E
```

Random point $P=(P_x,P_y)$ of an elliptic curve $E$ is the shared secret and a seed of the key sequence.

Let $K=K_0K_1\cdots$ be a key sequence. Then:

$K_i=\times([2^i]P)\ \textrm{mod}\ 2$

$K_i=1\ \textrm{if}\ [2^i]P\ \textrm{is the point at infinity}\ \mathcal{O}$

Where $\times(P)=P_x$ and $[2^i]P$ is a scalar multiplication between an integer $2^i$ and a point $P$.

### Elliptic curve $E$:

$E=\{\mathcal{O}\}\cup\{(x,y)\in K^2\mid y^2=x^3+ax+b\}$

Where $K=\mathbb{Z}_p$.

### Also:

We are given the $y$-coordinate of $[2^{2\mid M^\prime\mid}]P$


```python
G = IntegerModRing(p)
```

First, let's find the solutions of the elliptic curve equation with the given value $y$ :


```python
R.<u> = PolynomialRing(G, 'u')
f = (- y ** 2 + u ** 3 + a * u + b)
r = [i[0] for i in f.roots()]
print r
```

    [2863630260273906879738304382327082098766838571003235254560, 829539754520273617339926976669563027315213831455604281432, 215435968619537503897656783387023535044104393106441343301]


Now let's get these points in the elliptic curve :


```python
E = EllipticCurve(G, [0, 0, 0, a, b])
```


```python
points = [E(i, y) for i in r]
```

We can easily find the possible private keys using the inverse of $2^{2|M'|}$ and the three points ! The apprentice should not have given us the value $y$ !


```python
k = inverse_mod(2 ** (2 * len(C)), n)
possible_private_keys = [k * point for point in points]
```


```python
# decode_binary_string will decode a binary string using a given encoding [FOUND ON STACKOVERFLOW]
def decode_binary_string(s, encoding='utf-8'):
    byte_string = ''.join(chr(int(s[i*8:i*8+8],2)) for i in range(len(s)//8))
    return byte_string.decode(encoding)

def decrypt(P):
    plaintext = []
    two_i = 1
    for i, b in enumerate(C):
        Ki = mod((two_i * P)[0], 2)
        Mi = mod(Ki + int(b), 2)
        plaintext.append(str(Mi))
        two_i *= 2
    try:
        plain = decode_binary_string(''.join(plaintext), 'ascii')
        return plain
    except:
         return ''
```


```python
for P in possible_private_keys:
    d = decrypt(P)
    if d != '':
        print d
        break
```

    Revenge? Revenge! The King under Raglan is dead and where are his kin that dare seek revenge? Girion Lord of Dwarf is dead, and I have eaten his people like a wolf among sheep, and where are his sons' sons that dare approach me? I kill where I wish and none dare resist. I laid low the warriors of old and their like is not in the world today. Then I was but young and tender. Now I am old and strong, strong, strong, Thief in Siestas!
