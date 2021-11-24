# Indexed Sparse Merkle Tree

This implementation of an index sparse merkle tree allows inserting a
new leaf only, if valid proof and the old leaf can be presented such
that those compute the current tree's root.

## Why use this?

- Implementation is [gas optimized](https://ethresear.ch/t/optimizing-sparse-merkle-trees/3751?u=timdaub)


## Run Tests

```bash
dapp test -vv
```

## LICENSE

See LICENSE file.
