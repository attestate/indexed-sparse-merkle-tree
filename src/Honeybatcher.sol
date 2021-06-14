pragma solidity ^0.6.7;

import "ds-token/token.sol";
import "./StateTree.sol";

contract Honeybatcher {
  StateTree public tree;
  bytes32 public root;

  constructor() public {
    tree = new StateTree();
    root = tree.root();
  }

  function deposit(
    bytes32[] memory proof,
    address token,
    uint256 amount
  ) public {
    DSToken(token).transferFrom(msg.sender, address(this), amount);
    tree.write_insertion(
      proof,
      abi.encodePacked(token, msg.sender, amount)
    );
    root = tree.root();
  }
}
