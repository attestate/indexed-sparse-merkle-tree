pragma solidity ^0.6.7;

import "openzeppelin-contracts/cryptography/MerkleProof.sol";
import "ds-token/token.sol";

contract TxAggregator {
  bytes32 public root;

  function deposit(
    bytes32[] memory proof,
    bytes32 newRoot,
    address token,
    address from,
    uint256 amount
  ) public {
    bytes32 leaf = keccak256(abi.encodePacked(token, from, amount));
    require(MerkleProof.verify(proof, newRoot, leaf));

    // TODO: For being able to use this function in a batch transaction, we need
    // to ensure that it can fail gracefully
    DSToken(token).transferFrom(from, address(this), amount);
    root = newRoot;
  }
}
