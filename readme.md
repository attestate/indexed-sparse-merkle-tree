<p align="center">
  <img src="/assets/logo.png" />
</p>

[![lint: prettier-solidity](https://github.com/attestate/indexed-sparse-merkle-tree/actions/workflows/lint.yml/badge.svg)](https://github.com/attestate/indexed-sparse-merkle-tree/actions/workflows/lint.yml) [![unit tests](https://github.com/attestate/indexed-sparse-merkle-tree/actions/workflows/main.yml/badge.svg)](https://github.com/attestate/indexed-sparse-merkle-tree/actions/workflows/main.yml)

### A dapptools-ready and gas-optimized implementation of a sparse merkle tree in Solidity. 
#### [Installation](readme.md/#Installation) | [Usage](readme.md/#Usage) | [Contributing](readme.md/#Contributing) | [Gas-usage Benchmark Results](.gas-benchmark)

## Why use it?

- This implementation is **[gas
  optimized](https://ethresear.ch/t/optimizing-sparse-merkle-trees/3751)**
  according to a ethresear.ch post from Vitalik Buterin and others.
- It's [dapptools](https://github.com/dapphub/dapptools)-compatible and so all
  tests are written in Solidity: **Maintenance is improved**.

## Installation

### Prerequisites

- You need to have [dapptools](https://github.com/dapphub/dapptools) installed.

### Including as a dapptools dependency

```bash
dapp install attestate/indexed-sparse-merkle-tree
```

Once you've done that, you can use the `StateTree.sol` contract class
`StateTree` to initialize the merkle tree.

## Usage

Here's an example of how `StateTree.sol` could be used. Here,
`StateTree.empty()` computes the default empty sparse merkle tree. That root is
then stored in a `bytes32` storage variable when `Dapp` is initialized.

```sol
pragma solidity ^0.8.6;
import "indexed-sparse-merkle-tree/StateTree.sol";

contract Dapp {
  bytes32 public root;

  constructor() {
    root = StateTree.empty();
  }
}
```

## How Do Sparse Merkle Trees Work?

Sparse Merkle Trees (short: SMT) are regular merkle trees (or sometimes called
"hash trees"). For brevity, we're not going to go into details about how merkle
trees work, but only what the "sparse" attribute means.

Generally speaking, a merkle tree has, as a base layer, a number of leaves that
are being hashed. But the core assumption of a merkle tree is that most or all
leaves on the base layer have data in them. Here's a classical example of a
binary hash tree.

<p align="center">
  <img src="/assets/hashtree.svg" />
</p>

Now for sparse merkle tree, the default assumption is that all leaves at the
tree's birth are empty. And this empty value is usually represented by some
kind of value. In programming languages terms like `void`, `null`, `nil` are
often used to represent emptiness. However, since we want to hash all leaf
values using a hash function like e.g. sha3, we'll have to somehow represent
emptiness nominally. Hence, when calling `StateTree.empty()`, the tree's
initializing function, we generate a list of leaves all empty and represented
by zeros:

```
leaves = [0, 0, ...,0];
```

And we then hash those leaves exactly the same way we'd hash a regular merkle
tree.

### So why use a **sparse** merkle tree in the first place?

A merkle tree is great for validating the integrity of an existing file. E.g.
in Bittorrent, when someone posts a magnet link to a movie, then knowing the
movie file's hash is useful as it helps to verify the integrity of the movie
currently downloaded.

But e.g. in the case of storing data structures on-chain as is done with
decentralized apps, a sparse merkle tree that is initially empty but can be
updated to contain more and more values, is kinda neat.

E.g. after we initialized our tree with `StateTree.empty()`, we can then write
values into any of the leaves by calling `StateTree.write()` to receive a new
root. An example:

```sol
bytes32[] memory proofs = new bytes32[](0);
bytes32 OLD_LEAF_HASH = keccak256(
  abi.encode(
    0x0000000000000000000000000000000000000000000000000000000000000000
  )
);
bytes32 NEW_LEAF_HASH = keccak256(
  abi.encode(
    0x0000000000000000000000000000000000000000000000000000000000000001
  )
);
uint8 bits = 0;
uint256 index = 0;

bytes32 ROOT0 = StateTree.empty();
bytes32 ROOT1 = StateTree.write(
  proofs,
  bits,
  index,
  NEW_LEAF_HASH,
  OLD_LEAF_HASH,
  ROOT0
);
```

See, in the above example, we proposed overwriting the old value of the tree
`OLD_LEAF_HASH` with a new value `NEW_LEAF_HASH`. We said that in the tree
itself we want to write the leaf at `index = 0`. There's also two variables not
being used yet: `proofs` and `bits`.

Normally, for each insertion to have the `write` function succeed, we have to
provide a valid old merkle root hash. This is because internally, `write` first
checks with `validate` if by reinserting `OLD_LEAF_HASH` we get the same old
root as we claimed with `ROOT0`.

Only if that's the case, we're allowed to proceed to actually attempt
computation of the new root `ROOT1`.

In smart contract programming, originally (sparse) merkle trees were used to
validate integrity. But with the rise of the rollup infrastructures, it's
become known that SMTs might also allow to build linearly scalable dapps by
saving gas costs when storing words in the EVM's state.

### Why sparse merkle trees could safe you gas

Storing a non-zero word of 32 bytes for the first time in EVM storage currently
costs 20k gas. However, including many 32bytes leaves into an SMT might cost
less than 20k gas per 32bytes. A user or operator would still have to pay for
the tree's root inclusion into the chain, e.g. by storing it as a storage
variable - but even for large body of data, cost would decrease. Generally
speaking, most cost would occur when having to compute the new root.

### Using `write` with `uint8 bits`

A special property of this sparse merkle tree is that it is gas-optimized
according to a post from
[ethresear.ch](https://ethresear.ch/t/optimizing-sparse-merkle-trees/3751). In
general, a sparse merkle tree of binary structure has a mandatory proof size of
its depth. In simpler terms, this means that for an SMT with depth eight, for
any type of recomputation eight other nodes on various levels would have to be
necessary. Actually, there's a really great article by Vitalik called
"[Merkling in
Ethereum](https://blog.ethereum.org/2015/11/15/merkling-in-ethereum/) that may
help to understand this property.

But in any case, at e.g. a depth of 256 and having 2^256 leaves, requiring 256
proofs of 32 bytes ends up being a lot of data; that doesn't sound gas
efficient at all. And that were Vitalik's post on "[Optimizing sparse Merkle
trees](https://ethresear.ch/t/optimizing-sparse-merkle-trees/3751)" comes in
handy. Because, if we assume that most of our tree will mostly remain
relatively empty, then we can precompute the leaves that just represent zero
values on all sorts of levels.

For that, e.g. imagine a sparse merkle tree with just a single non-zero leaf at
the left hand side. If we looked at it, we'd immediately see that all other
leaf nodes are zero hashes. We'd also understand that even for the most top
right node, closest to the root node, it could be precomputed too and would
simply be the accumulation of all zero node hashes on the last seven levels.

Indeed, the `StateTree` has all these values available precomputed in the
`get(uint256 level)` function. And that's how we can safe gas costs, by
reducing the number of proofs required to update the tree. Going back to our
example earlier:

```sol
bytes32[] memory proofs = new bytes32[](0);
bytes32 OLD_LEAF_HASH = keccak256(
  abi.encode(
    0x0000000000000000000000000000000000000000000000000000000000000000
  )
);
bytes32 NEW_LEAF_HASH = keccak256(
  abi.encode(
    0x0000000000000000000000000000000000000000000000000000000000000001
  )
);
uint8 bits = 0;
uint256 index = 0;

bytes32 ROOT0 = StateTree.empty();
bytes32 ROOT1 = StateTree.write(
  proofs,
  bits,
  index,
  NEW_LEAF_HASH,
  OLD_LEAF_HASH,
  ROOT0
);
```

We can see that `proofs` and `bits` is actually empty, as all zero-value hashes
can be used from within the actual implementation. So not a single proof has to
be put into calldata.

If, however, we were to now enter a second value at another index into the tree
we'd have to start getting creative. See, `bits` indicates at which level we
have to send in a custom proof and can't use a pre-computed zero proof.

```sol
// continued from code snippet above...

uint256 proofIndex = 0;
uint8 bytePos = (bufLength - 1) - (proofIndex / 8);
uint8 bits2 = bytePos + 1 << (proofIndex % 8);

bytes32[] memory proofs2 = new bytes32[](1);
proofs2[0] = NEW_LEAF_HASH;

uint256 index2 = 1;
bytes32 ROOT2 = StateTree.write(
  proofs2,
  bits2,
  index2,
  NEW_LEAF_HASH,
  OLD_LEAF_HASH,
  ROOT1
);
```

So in this case, we're hence making the `write` function understand that at
`proof2[0]`, there's a non-zero proof for the computation. We've done so by
computing a bit map on a `uint8 bits2` value. This looks like some rather
intimidating math, but what it really does is it flips the first zero value of
an integer represented in binary to a one. E.g. `0000` to `1000`.

For the user's convenience however, we're shipping this bitmap function in the
code too. Just call `bitmap(uint256 index)`.

## Contributing

You can download this repository and test the implementation using the
following command:

```bash
dapp test -vv
```

## LICENSE

See LICENSE file.
