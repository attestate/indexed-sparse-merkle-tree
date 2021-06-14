pragma solidity ^0.6.7;

import "ds-test/test.sol";
import "./StateTree.sol";

contract StateTreeTest is DSTest {
  StateTree public tree;
  function setUp() public {
    tree = new StateTree();
  }
}
