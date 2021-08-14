# Verilog bitcoin

This project aims to express Bitcoin mining in the Verilog language. 

This project contains two approaches, a static logic and clockless design and a design that computes the hashes in 128 clock cycles. The former would be more appropriate in an ASIC design, since it uses much more logic than the latter. However for experimenting with FPGAs, the latter is more reasonable. 

# Brief explination of Bitcoin hashing

The algorithm for calculating the Bitcoin block hash is 

```
SHA256(SHA256(Block_Header))
```

where the Block_Header is defined as a struct containing

- Version (4 bytes)
- Hash of previous block (32 bytes)
- Merkle root hash (32 bytes)
- Time (4 bytes)
- Bits (4 bytes)
- Nonce (4 bytes)

This readme will not go into further detail of the block hashing algorithm, only outline the decisions made for the verilog implementation. See [this](https://en.bitcoin.it/wiki/Block_hashing_algorithm) for more information.

# First hash

The very first hash takes the 80 byte block header and computes its hash. It is important to note that when mining a particular block, the only aspect that changes between hash calculations is the nonce. This means that the first 512 bits of the block header don't change. We can leverage the SHA-256 algorithm to take advantage of this by pre-calculating the hash for the first 512 bytes. This only needs to be done once per block and can be reused for each nonce. 

This is how this implementation works, so the user must input the hash of the first 512 bit before starting the calculation. Warning: This pre hash must be calculated as the hash of a single SHA block, so no padding must be added. TO obtain this the user must calculate the hash of the 512 bit chunk (without padding). 

Calculating this pre hash once per block (by the controller) saves having to calculate the hash for 2 chunks. 

# Second hash

The second hash is calculating by taking the hash of the first hash. Since the hash is only 256 bits, only one block is required.

# SHA core

The SHA-256 algorithm itself is designed to calculate the hash of a 512-bit block in 64 clock cycles. At the rising edge of each cycle values are moved in shift registers, and at the falling edge the counter is incremented. Designing it this way means that, even though the total bitcoin check process takes 128 cycles, it vastly reduces the area of the circuit. 

# Test

At the end of the 128 cycles, the final hash is compared to the target and if the hash is less than or equal to it, the module outputs a 1. 

# Nonce offset

The controller must send the nonce to each device, but each device can be preprogrammed with a nonce offset. This is added to the nonce sent to the device to obtain the nonce used in the hash. This easily allows multiple instances of the device to be connected together without having to send a unique nonce to each one. A single nonce is broadcast, and each device then calculates its own nonce to use.  

# Initialisation

When the devices start a new block, the following data must be sent to each device:

- Pre hash (hash of first 512 bits. See First hash heading for more information)
- Merkle (last 32-bits of the merkle hash)
- Bits 
- Time

These values are stored and kept until either a) the device resets/powers down or b) a new block is started. This means that the only values that must be sent each nonce calculation is the global nonce itsef. One final piece of data must be sent, and that is the first nonce

- First global nonce

Subsequent nonces must be sent every 128 clock pulses, i.e. at the start of the calculation.

# Bitcoin hash core

Each bitcoin hash core is capable of computing one bitcoin hash (i.e. testing a single nonce) every 128 clock cycles.

# Array

Each array contains `CORE_COUNT` cores. Each array is given a unique `nonce_scalar` (externally wired, like an I2C address) 

each nonce is calculated as nonce = GLOBAL_NONCE +  (CORE_COUNT * nonce_scalar) + NONCE_OFFSET. 

Think of cores as a 2D array that is width CORE_COUNT and the height is the number of arrays. 

The idea is to ensure that if we use multiple arrays, and each array has multiple cores, each core gets a unique nonce without wasting time sending nonces to each core/array. By chosing the correct parameters and externally wiring each nonce_scalar, we can ensure each core is given a unique nonce.

# Reset line

Instead of going from low to high and staying high, the reset line must be clocked to initiate (low, high, low), During normal operation, the reset line must be kept low. 