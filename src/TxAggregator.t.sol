pragma solidity ^0.6.7;

import "ds-test/test.sol";
import "ds-token/token.sol";
import "openzeppelin-contracts/cryptography/MerkleProof.sol";

import "./TxAggregator.sol";

contract TxAggregatorTest is DSTest {
    TxAggregator aggregator;
    DSToken token;

    function setUp() public {
        aggregator = new TxAggregator();
        token = new DSToken("T");
    }

    // NOTE: For now, this test serves no other function as to understand how
    // OZ's MerkleProof.sol works.
    function test_merkle() public {
      bytes32 zero = 0x0000000000000000000000000000000000000000000000000000000000000000;
      bytes32 one = 0x0000000000000000000000000000000000000000000000000000000000000001;
      bytes32 hZero = keccak256(abi.encodePacked(zero));
      bytes32 hOne= keccak256(abi.encodePacked(one));
      bytes32 root = keccak256(abi.encodePacked(hZero, hOne));
      bytes32[] memory proof = new bytes32[](1);
      proof[0] = hZero;
      assertTrue(MerkleProof.verify(proof, root, hOne));
    }

    function test_deposit() public {
      uint256 amount = 1;
      address t = address(token);
      address from = address(this);
      token.mint(amount);
      token.approve(address(aggregator), amount);

      bytes32 left = 0x0000000000000000000000000000000000000000000000000000000000000000;
      bytes32 hLeft = keccak256(abi.encodePacked(left));

      bytes32 leaf = keccak256(abi.encodePacked(token, from, amount));
      bytes32 root = keccak256(abi.encodePacked(hLeft, leaf));
      bytes32[] memory proof = new bytes32[](1);
      proof[0] = hLeft;

      aggregator.deposit(proof, root, t, from, amount);
      assertEq(root, aggregator.root());
    }
}
