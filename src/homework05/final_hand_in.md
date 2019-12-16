# Crypto Homework 5 ~ Louis Merlin

## Exercise 1 ~ A full round trip? Ain’t nobody got time for that!


```python
import socket
import hashlib
import binascii
import utils
# Get variable from parameters file
params = utils.get_parameters()
```


```python
p = params.Q1_p
q = params.Q1_q
g = params.Q1_g
pk = params.Q1_pk
sk = params.Q1_sk
```


```python
def connect_server(server_name, port, message):
    server = (server_name, int(port)) #calling int is required when using Sage
    s = socket.create_connection(server)
    s.send(bytes(message + "\n"))
    response=""
    while True: #data might come in several packets, need to wait for all of it
        data = s.recv(1024)
        data = data.decode("ASCII")
        if len(data) == 0:
            break
        if data[-1] == '\n': 
            response += data[:-1]  
            break
        response += data
    s.close()
    return response


def oracle_query(sciper):
    server_name = "lasecpc25.epfl.ch"
    port = "5559"
    message = sciper 
    response = connect_server(server_name, port, message)
    #print(response)
    return response

# Returns a binary oracle_query
def bin_query():
    return bin(int(oracle_query("247565"), 16))[2:].zfill(16752)
```


- iterate over the blocks (2000 mixed with 256) of the query and find the value $a$ for which $a^q=1\textrm{ mod }p$ and $a!=1\textrm{ mod }p$ => $a$ is $X_0$.
- Once we have $X_0$, we can find $pk^{x_0}$ with $X_0^{sk}$
- Then, we try to decrypt the blocks with the St values we compute
- We find the block with *password*


```python
def encode(a, n=256):
    x = bin(a)[2:].zfill(n)
    return x[-n:]

def kdf(st):
    hex_value = hex(int(st, 2))[2:]
    if hex_value[-1] == 'L':
        hex_value = hex_value[:-1]
    hex_value = hex_value.zfill(64)
    k_to_hash = binascii.unhexlify("00" + hex_value)
    s_to_hash = binascii.unhexlify("ff" + hex_value)
    k = bin(int(hashlib.sha256(k_to_hash).hexdigest(), 16))[2:].zfill(256)
    s = bin(int(hashlib.sha256(s_to_hash).hexdigest(), 16))[2:].zfill(256)
    return s, k

def xor(a, b):
    c = ''
    for i in range(len(a)):
        if a[i] == b[i]:
            c += '0'
        else:
            c += '1'
    return c
```


```python
result = ''

while result == '':
    query = bin_query()
    integers = []
    blocks = []
    check = 0
    while len(integers) < 3:
        if check + 2000 > len(query):
            break
        X = int(query[check:check+2000], 2)
        if power_mod(X, q, p) == 1:
            integers.append(X)
            check += 2000
        else:
            blocks.append(query[check:check+256])
            check += 256
    for i in integers:
        St = encode(power_mod(i, sk, p))
        for _ in range(len(blocks)):
            St, ki = kdf(St)
            for block in blocks:
                m = xor(block, ki)
                n = int(m, 2)
                try:
                    s = binascii.unhexlify('%x' % n)
                    if s.find("password") != -1:
                        result = s
                except:
                    ''

print result
```

    .com&password=qmK-GnH-6WM-bgo&ti


## Exercise 2 ~ SHA2 Sponge


```python
import hashlib
import binascii
import utils
# Get variable from parameters file
params = utils.get_parameters()
```


```python
r = params.Q2_r
c = params.Q2_c
d = params.Q2_d
m = params.Q2_m
```


```python
def base64_to_bin(m):
    return hex_to_bin(binascii.b2a_hex(binascii.a2b_base64(m)))

def hex_to_bin(h):
    return bin(int(h, 16))[2:].zfill(512)

def bin_to_dat(b):
    h = '%x' % int(b, 2)
    return binascii.unhexlify(h.zfill(128))
    
def xor(a, b):
    c = ""
    for i in range(len(a)):
        if a[i] == b[i]:
            c += "0"
        else:
            c += "1"
    return c
```


```python
def sha2_sponge(r, c, d, m):
    hash_method = hashlib.sha512
    m += "101" + "0" * ((-(len(m)+4)) % r) + "1"
    s = "0" * (r + c)
    for i in range(len(m) / r):
        s = hex_to_bin(hash_method(bin_to_dat(xor(s, m[i * r:(i + 1) * r] + "0" * c))).hexdigest())
    h = ""
    for _ in range(d / r):
        h += s[0:r]
        s = hex_to_bin(hash_method(bin_to_dat(s)).hexdigest())
    if d % r != 0:
        h += s[0:d % r - 1]
    return h

m_bin = base64_to_bin(m)

h_bin = sha2_sponge(r, c, d, m_bin)

h = binascii.b2a_base64(bin_to_dat(h_bin))[:-1] # The -1 is because there is a newline at the end for some reason

print h
```

    uFZulVfJCpgUeyt8sf5hJGQDmLmhlPck0pOOcpVmPWic82657VYLtliFK6tdRR7xdTMoRzsn+25J/L+pxdbzxQ1DX83q/6gvn69soJWEG4lBs+AvxEFw/HC0mBtflTStWBC0GQ==



## Exercise 3 ~ Interactive Password-based Authentication


```python
import socket
import binascii
import random
import hashlib
import base64
from Crypto.Cipher import AES
import utils
# Get variable from parameters file
params = utils.get_parameters()
```


```python
Q3_id = params.Q3_id
```


```python
server = None

def send_message(message):
    global server
    server_name = "lasecpc25.epfl.ch"
    port = "7777"
    if server == None:
        server = socket.create_connection((server_name, int(port)))
    server.send(bytes(message + "\n"))
    response=""
    while True: #data might come in several packets, need to wait for all of it
        data = server.recv(1024)
        data = data.decode("ASCII")
        if len(data) == 0:
            break
        if data[-1] == '\n': 
            response += data[:-1]  
            break
        response += data
    return response

def close_conn():
    global server
    if server != None:
        server.close()
        server = None
```


```python
def base64_to_bin(m, l=128):
    return hex_to_bin(binascii.b2a_hex(binascii.a2b_base64(m)), l)

def hex_to_bin(h, l=128):
    return bin(int(h, 16))[2:].zfill(l)

def bin_to_dat(b, l=32):
    h = '%x' % int(b, 2)
    return binascii.unhexlify(h.zfill(l))

def bin_to_base64(b):
    return base64.b64encode(bin_to_dat(b))
    
def xor(a, b):
    c = ""
    for i in range(len(a)):
        if a[i] == b[i]:
            c += "0"
        else:
            c += "1"
    return c
```


```python
def exchange_part_1(i):
    m_1 = ' ' * 128
    while m_1[i] != '0':
        close_conn()
        m_1_b64 = send_message(Q3_id)
        m_1 = base64_to_bin(m_1_b64)
    return m_1
    
def create_m_0(i, bit, m_1):
    k = None
    m_0 = ' ' * 128
    while k != i or m_0[i] != bit:
        m_0 = ''.join([str(random.randrange(2)) for _ in range(128)])
        to_hash = Q3_id + bin_to_dat(m_0) + bin_to_dat(m_1)
        c = hex_to_bin(hashlib.sha512(to_hash).hexdigest(), 512)[:256]
        k = int(c[0:8], 2) % 128
    return m_0


def exchange_part_2(m_0):
    m_0_b64 = bin_to_base64(m_0)
    ch_0 = send_message(m_0_b64)
    ch_1 = send_message(ch_0)
    return ch_0, ch_1
```


```python
s_0 = ""
s_1 = ""

i = 0
while i < 128:
    # Initiate the connection and get m_1
    m_1 = exchange_part_1(i)
    # Generate the m_0 needed to get a good c
    m_0 = create_m_0(i, '0', m_1)
    ch_0, ch_1 = exchange_part_2(m_0)
    if ch_1 != 'abort':
        s_0 += ch_0
        s_1 += ch_0
    else:
        m_1 = exchange_part_1(i)
        m_0 = create_m_0(i, '1', m_1)
        ch_0_2, ch_1_2 = exchange_part_2(m_0)
        s_0 += xor('1', ch_0_2)
        s_1 += ch_0_2
    i += 1
```


```python
aes_0 = AES.new(bin_to_dat('0' * 128))
aes_1 = AES.new(bin_to_dat('1' * 128))

print aes_0.decrypt(bin_to_dat(s_0))
print aes_1.decrypt(bin_to_dat(s_1))
```

    6Nqqagj:$^$tjx
    6Nqqagj:$^$tjx


## Exercise 4 ~ I have commitment issues.


```python
import utils
# Get variable from parameters file
params = utils.get_parameters()
```


```python
Sciper = params.Sciper
p = params.Q4_p
g = params.Q4_g
h = params.Q4_h
Q4_list = params.Q4_list
c = params.Q4_c
```


```python
Zp = IntegerModRing(p)
Z2p = IntegerModRing(2 * p)
```


```python
g = (Zp(g[0]), Zp(g[1]))
```


```python
h = (Zp(h[0]), Zp(h[1]))
```


```python
c = (Zp(c[0]), Zp(c[1]))
```


$p$ is a large strong prime ($q=(p-1)/2$ is also prime).

Group $G$ : over $Z_p^*\times Z_p$.

Operation : $\forall (a,u),(b,v)\in Z_p^*\times Z_p\ :\ (a,u)*(b,v)=(ab,bu+av)$.

Commitment :
- commitment: $c=g^m*h^r$ with $r$ random.
- open: reveals $(m, r)$. Valid if $g^m* h^r=c$ and $(m,r)\in Z_{2p}\times Z_p$

$g^m=(g_0^m,mg_0^{m-1}g_1)$, this is very interesting.

$g^m*h^r=(g_0^mh_0^r,g_0^mrh_0^{r-1}h_1+h_0^rmg_0^{m-1}g_1)$

We can devise the following method to get back $r$ from a commitment and its message :


```python
def find_r(c, m):
    h_0_r = c[0] / g[0] ** m
    p2 = m * h_0_r * g[0] ** (m - 1) * g[1]
    p1 = c[1] - p2
    r = p1 / (g[0] ** m * (h_0_r / h[0]) * h[1])
    return r
```

### Part 1 : Hide and seek


```python
hiding = []

for (commitment, message) in Q4_list:
    commitment = (Zp(commitment[0]), Zp(commitment[1]))
    message = Z2p(message)

    r = find_r(commitment, message)
    
    if h[0] ** r == commitment[0] / g[0] ** message:
        hiding.append(1)
    else:
        hiding.append(0)
```


```python
print hiding
```

    [0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1]


### Part 2 : Reverse


```python
c = (Zp(c[0]), Zp(c[1]))
m = Z2p(Sciper)

r = find_r(c, m)

print r
```

    117512923558102318712780003841431543441288551349141343868489853727667224935974116311252220579237813527142808538425679102916801887312283985909109247449612148945145124281569806127503119193652424299832496138397971057863534222687211682015598204059402223429525785124039622750885975809328159154580203727150644340453

