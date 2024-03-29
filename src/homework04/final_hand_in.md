# Crypto Homework 4 ~ Louis Merlin

## Exercise 1 ~ DDH for Elliptic Curves

```python
Q1_q = 280276032511036912659747514949942733830293635567383496570426726520823098265214052605563217566504686971047960547846448439449
Q1_f = "x^2 + 1"
Q1_E = [0,1]
Q1_challenge = # REMOVED IN THE MARKDOWN FOR CONCISENESS
```

Let's create the Elliptic Curve necessary to carry out the rest of the assignment :


```python
field = PolynomialRing(Zmod(sqrt(Q1_q)), 'x')
x = field.gens()[0]
polynomial = x ** 2 + 1
quotient = field.quotient(polynomial, 'x')
x = quotient.gens()[0]
E = EllipticCurve(quotient, Q1_E)
```

Now, we can create the points and compute the Weil Pairing of g and C, and of A and B, that will ouput an nth root of unity in the base field. We can use this to see if the challenge is correct.


```python
response = []

for point in Q1_challenge:
    g = E(point[0])
    A = E(point[1])
    B = E(point[2])
    C = E(point[3])
    p1 = g.weil_pairing(C, Q1_q - 1)
    p2 = A.weil_pairing(B, Q1_q - 1)
    if p1 == p2:
        response.append(1)
    else:
        response.append(0)
```


```python
print response
```

    [0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1]


## Exercise 2 ~ Bat-Stream


```python
Q2_N = 80
Q2_A = # REMOVED IN THE MARKDOWN FOR CONCISENESS
Q2_c1 = # REMOVED IN THE MARKDOWN FOR CONCISENESS
Q2_c2 = # REMOVED IN THE MARKDOWN FOR CONCISENESS
```

We can deduce from the handout that a message ends with **I am batman!#** and the last block is padded with zeroes.

### Encrypt algorithm :

Stream is the message

K is the private key

A is the array Q2_A

N is 80, the block size

```
def encrypt(Stream, K, A, N): # msg, s_key, public array, 80
    while True:
        B = ""
        counter = 0
        S = K # private key
        C = ""
        while True:
            if counter % (N / 8) == 0 and len(B) != 0:
                C += bitwise_xor(B, S)
                S *= transpose(A)
                B = ""
            m = Stream.get_byte()
            B += m
            counter++
            if m == "#":
                B = pad(B)
                C += bitwise_xor(B, S)
                return C
```

We will use `create_vector` to transform the encrypted messages into suitable vectors to perform different operations.


```python
def create_vector(message):
    ascii_codes = [ord(c) for c in message]
    v = []
    for code in ascii_codes:
        bits = []
        bin_code = bin(code)
        if len(bin_code) != 10:
            bin_code = bin_code.zfill(10)
        for index in range(2, len(bin_code)):
            if bin_code[index] == '1':
                bits.append(1)
            else:
                bits.append(0)
        v.append(bits)
    return v
```


```python
full_key = "m batman!#" + 9 * '\x00'
```

Let's compute the inverse-transpose of matrix A


```python
A_matrix = matrix(Integers(2), Q2_A)
A_inverse_transpose = 1/A_matrix.transpose()
```

Now, we use the fact that we know the last characters of the message to decode the whole thing !


```python
# For each ciphertext, find the decode key and decode the message
for ciphertext in [Q2_c1, Q2_c2]:
    for possible_key in range(10):
        # Find the key using the "I am batman#" hint
        key = full_key[possible_key:possible_key + 10]
        key_vector = vector(matrix(Integers(2), create_vector(key)))
        most_ciphertext = vector(matrix(Integers(2), create_vector(ciphertext[len(ciphertext) - 10:])))
        first_key = vector(matrix(Integers(2), key_vector + most_ciphertext))
        # Decode the ciphertext
        final_buffer = []
        for i in range(1, len(ciphertext)/10):
            ciphertext_vector = vector(matrix(Integers(2), create_vector(ciphertext[len(ciphertext) - 10 * i - 10:len(ciphertext) - 10 * i])))
            chunk_key = first_key * A_inverse_transpose
            chunk = ciphertext_vector + chunk_key            
            plaintext_final = []
            for i in range(0, len(chunk), 8):
                byte = 0
                for j in range(8):
                    byte += chunk[i + j].lift() << (7 - j)
                plaintext_final.append(byte)
            first_key = chunk_key
            final_buffer.append(''.join(chr(i) for i in plaintext_final))
        final_buffer.reverse()
        last_string = ''.join(final_buffer) + key
        # If the string seems printable, print it !
        if ord(last_string[0]) < 128 and ord(last_string[1]) < 128 and ord(last_string[2]) < 128 and ord(last_string[3]) < 128:
            print(last_string)
```

    Jim Gordon: Yours?(The Tumblers jumpes over Gordons head) Oh! Ive need to get one of those. Henri Ducard: If you make yourself more than just a man, if you devote yourself to an ideal and if they cant stop you, then you become something else entirely. Batman/Bruce Wayne: Or cheap parlor tricks to conceal your true identity, Ras? Henri Ducard: If you make yourself more than just a man, if you devote yourself to an ideal and if they cant stop you, then you become something else entirely. Batman/Bruce Wayne: Still havent given up on me? Lucius Fox: Mr. Wayne, if you dont want to tell me exactly what youre doing......when Im asked, I dont have to lie. But dont think of me as an idiot. Batman/Bruce Wayne: Or cheap parlor tricks to conceal your true identity, Ras? Batman/Bruce Wayne: Which is? Alfred Pennyworth: Quite. In the, uh, meantime, Sir, may I suggest you try to avoid landing on your head? Henri Ducard: But a criminal is not complicated. What you really fear is inside yourself. You fear your own power. You fear your anger, the drive to do great or terrible things. Batman/Bruce Wayne: You were on the board? Rachel Dawes: Its not who we are but what we do that defines us. Thomas Wayne: Why do we fall Bruce? To learn to stand up. Jim Gordon: I never said thank you. I am batman!#  
    Dr. Jonathan Crane/Scarecrow: Patients suffering delusional episodes often focus their paranoia on an external tormentor usually one conforming to Jungian archetypes. In this case, a scarecrow. Henri Ducard: Training is nothing.Will is everything.The Will to act.. Batman/Bruce Wayne: In the southeast corner? Batman/Bruce Wayne: At least they gave us a discount. Batman/Bruce Wayne: Which is? Batman/Bruce Wayne: My anger outweighs my guilt. Henri Ducard: You always need to be aware of your surroundings. Batman/Bruce Wayne: Its not who I am underneath, but what I *do* that defines me. Batman/Bruce Wayne: Ras al Ghul is dead. Who are you working for? Crane! Henri Ducard: Justice. Crime can not be tolerated. Criminals thrive on the indulgence of societys understanding. Lucius Fox: Mr Wayne, the way I see it, all this stuff is yours anyway. Earle: On whos authority? Ras Al Ghul: Of course. Over the ages, our weapons have grown more sophisticated. With Gotham, we tried a new one: Economics. But we underestimated certain of Gothams citizens...such as your parents. Gunned down by one of the very people they were trying to help. Create enough hunger and everyone becomes a criminal. Their deaths galvanized the city into saving itself...and Gotham has limped on ever since. We are back to finish the job. And this time no misguided idealists will get in the way. Like your father, you lack the courage to do all that is necessary. If someone stands in the way of true justice...you simply walk up behind them and stab them in the heart. Jim Gordon: I never said thank you. Jim Gordon: Ill get my car. I am batman!#        


## Exercise 3 ~ Modes of operation with counter


```python
import base64
import socket
import random
```


```python
Sciper = 247565
Np = 6779987342390324900
C = "qKKJWQAd0R7P/6Lsu7VZX3stpycRqODxcNcTzl6GN4PHLECQkXWjiUwnYVl3JlwWXurjiwY09sJYPNtygb8uLX1ncvW2fLI2vNqyq9RbEPRjbI6NexxyUyd36uKAriOte+lHu3tEFEDsEGVrIJmZ7hYmSAh/U9K94WWaganI5E2RsVeeRQtA9mNVqv3Df2x9K+Rq7gNpbEQ0TkIryj9TI4J7hh3cuWlPQGvVkS9sxJQYizCToP/SZo+cTcr0tU9P/4MgcROcTzEKOmMfk9QkJHE8NATFSmJ781qrqJish9tm+yO5mg9SY3qhGVXX1reos8LDjhZORQnKkfhfuZOyjA=="
```


```python
def connect_server(server_name, port, message):
    server = (server_name, int(port)) #calling int is required when using Sage
    s = socket.create_connection(server)
    s.send(message + "\n")
    response=""
    while True: #data might come in several packets, need to wait for all of it
        data = s.recv(1024)
        if len(data) == 0:
            break
        if data[-1] == '\n': 
            response += data[:-1]  
            break
        response += data
    s.close()
    return response
```


```python
def encrypt(m):
    while len(m) % 16 != 0:
        m += '\x00'
    encoded_m =  base64.b64encode(m)
    return base64.b64decode(connect_server("lasecpc25.epfl.ch", 6666, str(Sciper) + " " + encoded_m).encode("ASCII"))

def encrypt_no_base64(m):
    return connect_server("lasecpc25.epfl.ch", 6666, str(Sciper) + " " + m)
```

It would seem from the $Np$ value that the $AES-CTR*$ algorithm is used in the algorithm.

From the algorithm, it would seem like sending a string full of empty characters will give us:

$AES(K, LitEnd(N \textrm{ mod } 2^{64}) || BigEnd(N \textrm{ mod } 2^{64}))$

For two consecutive $N$s, the middle of V will be the same.


```python
modes = ["CBC*", "CTR*", "OFB*", "CFB*"]

def goToCBC():
    ciphers = set()
    ctr = 0
    for _ in range(3):
        for _ in range(4):
            ciphers.add(encrypt_no_base64('AAAAAAAAAAAAAAAAAAAAAA=='))
        for _ in range(8):
            x = encrypt_no_base64('BAAAAAAAAAAAAAAAAAAABA==')
            if x in ciphers:
                # We have found CBC ! Now let's increment N by 3 to go back to CBC for the next query
                encrypt_no_base64('AAAAAAAAAAAAAAAAAAAAAA==')
                encrypt_no_base64('AAAAAAAAAAAAAAAAAAAAAA==')
                encrypt_no_base64('AAAAAAAAAAAAAAAAAAAAAA==')
                return
```

Let's start with N=z

```
AES-CTR*(z, K, "\x00...\x00")
= AES(K, (LitEnd(z) || BigEnd(z)))

AES-OFB*(z+1, K, "\x00...\x00")
= AES(K, (LitEnd(z+1) || BigEnd(z+1))) || AES(K, AES(K, (LitEnd(z+1) || BigEnd(z+1)))

AES-CFB*(z+2, K, "\x00...\x00")
= AES(K, (LitEnd(z+2) || BigEnd(z+2))) || AES(K, AES(K, (LitEnd(z+2) || BigEnd(z+2))))

AES-CBC*(z+3, K, "\x00...\x00")
= AES(K, (LitEnd(z+3) || BigEnd(z+3))) || AES(K, AES(K, (LitEnd(z+3) || BigEnd(z+3))))
```

Using CBC*, we can basically reset the input of AES to "" (without leaking the whole N), and input whatever we want (e.g. the values of LitEnd(N-i) || BigEnd(N+i) with N=Np.


```python
# Get the big endian representation of a number
def big_endian(n):
    hex_representation = "{0:0>16x}".format(n)
    hex_numbers = [int(hex_representation[2*i:2*(i+1)], 16) for i in range(8)]
    return "".join(chr(k) for k in hex_numbers)

# Get the little endian representation of a number
def little_endian(n):
    return big_endian(n)[::-1]
```


```python
def string(bits):
    res = []
    for b in [bits[8*i:8*(i+1)] for i in range(len(bits)/8)]:
        res.append(chr(int("".join([str(i) for i in b]), 2)))
    return "".join(res)

def bits(string):
    return [[int(b) for b in "{0:0>8b}".format(ord(char))] for char in string]

def xor(b1, b2):
    return [b1[i] ^^ b2[i] for i in range(len(b1))]
```


```python
c = base64.b64decode(C)
cipher_blocks = [c[16*i:16*(i+1)] for i in range(len(c)/16)]

# These are the original keys derived from Np we will be using to get the real keys from the server
keys = "".join([(little_endian((Np - i) % 2^64) + big_endian((Np + i) % 2^64)) for i in range(len(cipher_blocks))])

blocks = [keys[16*i:16*(i+1)] for i in range(len(keys)/16)]

# We go to CBC mode (N % 8 = 3)
goToCBC()
keys_blocks = []
for b in blocks:
    # With CBC mode, we get the output of the next CTR if we give it the right input
    A = bits(encrypt(little_endian(5) + big_endian(5)))
    # Now N % 8 = 4
    [encrypt("whatever") for _ in range(2)]
    # Now N % 8 = 6 (OFB)
    # We pass it A xor the block
    res_b = encrypt(string(xor(bits(b), A))+ "\x00") 
    # Now N % 8 = 7
    # We store the result
    keys_blocks.append(res_b[16:])
    # We go back to CBC mode (N % 8 = 3)
    [encrypt("whatever") for _ in range(4)]

res = [string(xor(bits(keys_blocks[i]), bits(cipher_blocks[i]))) for i in range(len(cipher_blocks))]

print base64.b64encode("".join(res))
```

    9FZaks2/+lD1XYW8WaTssHfu8A35TWm0OnnDvjK/Scf6WOE+rJoAZTGwjVWEK8gSa05hqJzyjSQyRF6oBXeabiLomJQ9DDzJPLLqr2qNpn45RTNQd1O74AwLcwzDUNO/E4vCXXgGtSmpEAPtObIsjvZQEHyPaQV6edxliSUq8PXkkjGoqYzYgiJlLINwDyLthNjgaP8MxcCRf+fjinFmSTqnf54MY2n2X+U/immvPaUOmhKJH0uyVXUILLnGqLKceX2CkRFk0/t1Doq0AK07qxIYuXvgrhvcd6N23SbcKlw5m5ZMh7hgbBnpCgSThHFfQak88P9XFe3UAwr+gZk3OQ==


## Exercise 4 ~ Nibblet Blockcipher


```python
s = # REMOVED IN THE MARKDOWN FOR CONCISENESS
pin = [32, 4, 34, 51, 8, 29, 47, 10, 43, 48, 33, 19, 0, 52, 55, 16, 56, 25, 23, 14, 26, 27, 6, 15, 36, 17, 61, 20, 63, 11, 13, 49, 12, 5, 24, 50, 38, 30, 62, 2, 60, 21, 7, 1, 40, 22, 28, 31, 35, 41, 9, 45, 58, 53, 42, 18, 39, 57, 37, 3, 54, 59, 44, 46]
pout = [50, 33, 49, 54, 4, 60, 22, 47, 59, 46, 3, 8, 57, 35, 58, 45, 52, 18, 23, 6, 13, 53, 0, 26, 44, 37, 27, 10, 16, 42, 41, 1, 56, 2, 48, 31, 24, 7, 14, 17, 51, 30, 63, 20, 19, 55, 34, 5, 21, 61, 39, 12, 9, 62, 29, 32, 25, 36, 38, 11, 15, 43, 28, 40]
p = [[6, 7, 0, 1, 2, 3, 4, 5], [6, 7, 0, 1, 2, 3, 4, 5], [6, 7, 0, 1, 2, 3, 4, 5], [6, 7, 0, 1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 0, 1], [6, 7, 0, 1, 2, 3, 4, 5], [6, 7, 0, 1, 2, 3, 4, 5], [6, 7, 0, 1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 0, 1]]
m = "Now, now my good man, this is no time to be making enemies; said Voltaire on his deathbed in response to a priest asking him that he renounce the devil."
IV = "FFFFFFFFFF247565"
```

This question is quite straightforward, the goal is to implement the algorithm from the handout :

```python
# A few helper methods

def string_to_binary(s):
    return map(int, ''.join([bin(ord(i)).lstrip('0b').rjust(8,'0') for i in s]))

def nibble_to_int(n):
    return int(''.join([str(x) for x in n]), 2)

def hex_to_binary(h):
    return bin(int(h, 16))[2:]

def binary_to_hex(b):
    h = hex(int(''.join(b), 2))[2:]
    if h[-1] == 'L':
        return h[:-1]
    else:
        return h

# decode_binary_string will decode a binary string using a given encoding [FOUND ON STACKOVERFLOW]
def decode_binary_string(s, encoding='utf-8'):
    byte_string = ''.join(chr(int(s[i*8:i*8+8],2)) for i in range(len(s)//8))
    return byte_string.decode(encoding)

def xor(a, b):
    c = []
    for i in range(len(a)):
        if (str(a[i]) == str(b[i])):
            c.append('0')
        else:
            c.append('1')
    return c
```


```python
def RF(i, R):
    b = R
    B = []
    C = [[] for _ in range(8)]
    for j in range(8):
        B.append(b[4*j:4*j+4])
        # B[j] = s[i][j](B[j])
        B_int = nibble_to_int(B[j])
        s_bits = '{0:04b}'.format(s[i][j][B_int])
        B[j] = list(s_bits)
        # C[Pi[j]] = B[j]
        permutation = p[i][j]
        C[permutation] = B[j]
        # c[4*j:4*j+4] = C[j]
    # Z = c
    Z = [item for sublist in C for item in sublist]
    return Z
```


```python
def Enc(X):
    x = X
    y = ['' for b in x]
    for u in range(64):
        y[pin[u]] = x[u]
    R = []
    L = []
    L.append(y[0:32])
    R.append(y[32:64])
    for i in range(9):
        L.append(R[i])
        feistel = RF(i, R[i])
        R.append(xor(L[i], feistel))
    y = R[9] + L[9]
    z = ['' for b in y]
    for u in range(64):
        z[pout[u]] = y[u]
    Z = z
    return z
```


```python
def CBC(message):
    message_binary = string_to_binary(message)
    enc_out = hex_to_binary(IV)
    output = []
    for i in range(len(message_binary) / 64):
        enc_in = xor(enc_out, message_binary[64*i:64*(i + 1)])
        enc_out = Enc(enc_in)
        output.append(enc_out)
    output_bin = [item for sublist in output for item in sublist]
    return binary_to_hex(output_bin)
```


```python
encryption = CBC(m)
print encryption
```

    934960e8539b1d0a444cf93c7956a6c2b2743d37f3b4986c04f999fb653b23b75dfca85703cdfb0986e9028e14648f9463238378efbb4fb8cfa1538da8f46644eda474fee279b5750984ec84b9e80b35b40301448b6d1dc053c986d676f932fb5af63d4aae51011699f1cf7000522f088b21f3fcc5dc0f8a242c901702daf2890db9c3b07a43d75193f7d65be3783662ad66b1b2586c7882


## Exercise 5 ~ Nibblet Oracle


```python
import socket
from random import choice
```


```python
Sciper = "247565"
ct = "42a208e4c6beb1d7f3bd718f523345b73dec3f422ab9f0e1ec1b1278b02eb0d8e71296458e4733ed0444a5f8dc2df167abf4ad17fefdf3a1f62e180f8a3ee41c"
```

Let's get the server methods :


```python
def connect_server(server_name, port, message):
    server = (server_name, int(port)) #calling int is required when using Sage
    s = socket.create_connection(server)
    s.send(message + "\n")
    response=""
    while True: #data might come in several packets, need to wait for all of it
        data = s.recv(1024)
        if len(data) == 0:
            break
        if data[-1] == '\n': 
            response += data[:-1]  
            break
        response += data
    s.close()
    return response


def encryption_query(sciper, pt):
    server_name = "lasecpc25.epfl.ch"
    port = "5559"
    message = sciper + " " + pt
    response = connect_server(server_name, port, message)
    #print(response)
    return response
```


```python
print "Number of blocks :", len(ct) / 16
```

    Number of blocks : 8


The ciphertext has 8 blocks.

Here is a helper method to get random hexadecimal string :


```python
def rand_hex(l=16):
    hex_chars = "0123456789abcdef"
    h = []
    for i in range(l):
        h.append(choice(hex_chars))
    return ''.join(h)
```

And helper methods to convert hexadecimal to binary, and the other way around.


```python
def hex_to_binary(h):
    final_length = len(h) * 4
    b = bin(int(h, 16))[2:]
    while len(b) < final_length:
        b = '0' + b
    return b

def binary_to_hex(b):
    final_length = len(b) / 4
    h = hex(int(''.join(b), 2))[2:]
    if h[-1] == 'L':
        h = h[:-1]
    while len(h) < final_length:
        h = '0' + h
    return h
```

Let's try to see what impact flipping each bit has on the ciphertext :


```python
# This is how many flips we do for each bit 
ITER_NUM = 4

all_flipped_bits = []

for bit_to_flip in range(64): # For each bit in [0..64]
    flipped_bits = dict()
    for i in range(ITER_NUM): # Do this ITER_NUM times
        # Take a random hexadecimal value and encrypt it
        first_plain = rand_hex()
        first_enc = encryption_query(Sciper, first_plain)
        # Now flip the bit we are analysing, and encrypt that
        second_plain_bin_list = list(hex_to_binary(first_plain))
        if second_plain_bin_list[bit_to_flip] == '0':
            second_plain_bin_list[bit_to_flip] = '1'
        else:
            second_plain_bin_list[bit_to_flip] = '0'
        second_plain = binary_to_hex(second_plain_bin_list)
        second_enc = encryption_query(Sciper, second_plain)
        # Log the differences
        first_enc_bin = hex_to_binary(first_enc)
        second_enc_bin = hex_to_binary(second_enc)
        for j in range(len(first_enc_bin)):
            if first_enc_bin[j] != second_enc_bin[j]:
                if j in flipped_bits:
                    flipped_bits[j] += 1
                else:
                    flipped_bits[j] = 1
            else:
                if j not in flipped_bits:
                    flipped_bits[j] = 0
    all_flipped_bits.append([flipped_bits[x] for x in range(64)])
```

These represent the data we have aggregated in the previous cell.

Each line represents one bit that we flipped.

A "1" means the bit might be affected, and a "0" that it was never affected.


```python
all_flipped_bits_str = []
for f in range(len(all_flipped_bits)):
    s = ''
    for i in range(len(all_flipped_bits[f])):
        if all_flipped_bits[f][i] == 0:
            s += '0'
        else:
            s += '1'
    all_flipped_bits_str.append(s)
    print s
```

    0100000011000001011100001000000001100000000000010000100101000011
    0000100100100110000010000010010010000100000001100001000000010100
    1001011000000000000001100001001000000011100000001000000000101000
    1001011000000000000001100001001100000011101000001000000000101000
    0010000000011000000000010100100000011000010100000100011010000000
    0000100100100110000010000010010010000000000001100001000000010100
    0000100100100110000010000010010000000100000001100001000000010100
    0100000011000001001100001000000000100000000000010000100101000011
    1001011000000000000001100001001100000011101000001000000000101000
    0010000000011000100000010100100000011000010110000100010010000000
    1001011000000000000001100001001100000011101000001000000000100000
    0000100100100110000010000010010010000100000001100011000000010100
    1001011000000000000001000001001100000011101000001000000000101000
    0000100100100110000000000010010010000100000001100011000000010100
    1001011000000000000001100001001100000011101000001000000000101000
    0000100100100110000010000010010010000100000001100011000000010100
    0100000011000001010100001000000001100000000000010000100101000011
    0010000000011000100000010100100000011000000110000100011010000000
    0100000011000001011100001000000001100000000000010000100101000011
    0001001000000000000001100001001100000011100000001000000000101000
    1001011000000000000001100001001100000001101000001000000000101000
    1001011000000000000001100001001100000011101000001000000000101000
    1001011000000000000001100001001100000011101000001000000000101000
    0100000011000001011100001000000001100000000000000000100100000011
    0010000000011000100000010100100000011000010110000100011010000000
    1001011000000000000001000001001100000011101000001000000000101000
    0100000011000001010100001000000001100000000000010000100101000011
    0100000001000001011100001000000001100000000000010000100101000011
    0010000000011000100000000100100000011000010110000100011010000000
    0010000000011000100000010100100000011000010110000100011010000000
    0000100100100110000010000010010010000100000001100011000000010100
    0100000011000000011100001000000001100000000000010000100101000011
    0100000011000001011100001000000001100000000000010000100101000011
    0010000000011000100000010100100000011000010110000100011000000000
    0000100100100110000010000000010010000100000001100011000000010100
    0000100100100110000010000010010010000100000001000011000000010100
    1001011000000000000001100001000100000011101000001000000000001000
    0010000000011000100000010100100000010000010110000100011010000000
    0000100100100110000010000010010010000000000001100011000000010100
    0100000011000001011100001000000001100000000000010000100101000011
    0100000011000001011100001000000001100000000000010000100101000011
    0010000000011000100000010100100000011000010110000100011010000000
    0000000011000001011100001000000001100000000000010000100101000011
    0010000000011000100000010100100000011000010110000100011010000000
    0010000000011000100000010100100000011000010110000100011010000000
    0100000011000001011100001000000001100000000000010000100101000011
    0000100100100110000010000010010010000100000001100011000000010100
    0100000011000001011100001000000001100000000000010000100100000011
    0100000011000001011100001000000001100000000000010000100101000011
    0000100000100110000010000010010010000100000001100011000000010100
    0010000000011000100000010100100000011000010010000100011010000000
    0000100100100110000010000010010010000100000001100011000000010100
    0000100100100110000010000010010010000100000001100011000000010100
    1001011000000000000001000001001000000011101000001000000000101000
    0010000000011000100000010100100000001000010110000100011010000000
    0010000000011000100000010100100000011000010110000100011010000000
    0010000000011000100000010000100000011000010110000100011010000000
    0000100100100110000010000000010010000100000001100011000000010100
    1001011000000000000001100001001100000011101000001000000000101000
    1001011000000000000001100001001100000011101000001000000000101000
    0010000000011000100000010100100000011000010110000100011010000000
    0001011000000000000001000001001100000011101000001000000000101000
    0100000011000001011100000000000001100000000000010000100000000010
    0000000100100010000010000010010010000100000001100011000000010000


There seem to be many similar lines.

One reason could be that a subset of input bits only affect a certain other subset of output bits. Let's test this intuition :


```python
groups = []
for i in range(64):
    for j in range(len(all_flipped_bits_str)):
        for k in range(len(all_flipped_bits_str)):
            if all_flipped_bits_str[j][i] == '1':
                if all_flipped_bits_str[k][i] == '1':
                    found_group = False
                    for (l, m) in groups:
                        if (k in l) and (j not in l):
                            l.add(j)
                        if (j in l):
                            m.add(i)
                            found_group = True
                            break
                    if found_group == False:
                        groups.append((set([j]), set([i])))
groups = [(list(sorted(s)), list(sorted(m))) for (s, m) in groups]
print groups
```

    [([2, 3, 8, 10, 12, 14, 19, 20, 21, 22, 25, 36, 53, 58, 59, 61], [0, 3, 5, 6, 21, 22, 27, 30, 31, 38, 39, 40, 42, 48, 58, 60]), ([0, 7, 16, 18, 23, 26, 27, 31, 32, 39, 40, 42, 45, 47, 48, 62], [1, 8, 9, 15, 17, 18, 19, 24, 33, 34, 47, 52, 55, 57, 62, 63]), ([4, 9, 17, 24, 28, 29, 33, 37, 41, 43, 44, 50, 54, 55, 56, 60], [2, 11, 12, 16, 23, 25, 28, 35, 36, 41, 43, 44, 49, 53, 54, 56]), ([1, 5, 6, 11, 13, 15, 30, 34, 35, 38, 46, 49, 51, 52, 57, 63], [4, 7, 10, 13, 14, 20, 26, 29, 32, 37, 45, 46, 50, 51, 59, 61])]


Gotcha ! There are four different groups of bits that affect four different groups of bits ! This will give us a way to reverse the ciphertext.

We can use a "simple" exhaustive search : we have reduced our search space to $2^{16}$ values.

Let's first create all possible values of the 16 bits :


```python
plain_m = ''

for i in range(2 ** 16):
    bin_i = '{0:016b}'.format(i)
    temp_m = [' ' for _ in range(64)]
    for (g, _) in groups:
        for j in range(len(g)):
            temp_m[g[j]] = bin_i[j]
    plain_m += ''.join(temp_m)

plain_hex_m = binary_to_hex(plain_m)
```

Now we can encrypt all of those values, and we should be able to deconstruct our ciphertext using the output.


```python
enc_m = ''
split = 16
for i in range(split):
    m = plain_hex_m[i * len(plain_hex_m) / split:(i + 1) * len(plain_hex_m) / split]
    enc_m += encryption_query(Sciper, m)
```

Now we reconstruct the plaintext :


```python
my_flipped_bits = []
final_bin = [' ' for _ in range(len(ct) * 4)]
for block in range(len(ct) / 16): # For each 64-bit block of ct
    b = ct[block * 16:(block + 1) * 16]
    block_bin = hex_to_binary(b)
    temp_bin = [' ' for _ in range(len(block_bin))]
    for i in range(len(enc_m) / 16): # For each 64-bit block of enc_m
        enc_block = enc_m[i * 16:(i+1) * 16]
        enc_block_bin = hex_to_binary(enc_block)
        for g in groups:
            is_a_match = True
            for group_loc in g[1]:
                if enc_block_bin[group_loc] != block_bin[group_loc]:
                    is_a_match = False
            if is_a_match:
                h = plain_hex_m[i * 16:(i+1) * 16]
                h_bin = hex_to_binary(h)
                for group_loc in g[0]:
                    temp_bin[group_loc] = h_bin[group_loc]
    final_bin[block * len(block_bin):(block + 1) * len(block_bin)] = temp_bin
```


```python
print binary_to_hex(final_bin)
print encryption_query(Sciper, binary_to_hex(final_bin)) == ct
```

    e985260398b0d8f10d3762bc63308194791b3cf02a8c87bcdb3f8accf14f552a249076f97abd4324c3d9f134c2925c66105b17803931716a832b51f1288b9716
    True

