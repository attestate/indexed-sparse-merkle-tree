pragma solidity ^0.6.7;

import "ds-test/test.sol";
import "./StateTree.sol";

contract StateTreeTest is DSTest {
    function setUp() public {
    }

    function testSingleInsertion() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = StateTree.getEmpty();

        bytes32 first = 0x0000000000000000000000000000000000000000000000000000000000000002;
        bytes32 fLeaf = keccak256(abi.encodePacked(first));
        bytes32 actual = StateTree.compute(proof, fLeaf);

        bytes32 expected = keccak256(abi.encodePacked(StateTree.getEmpty(), fLeaf));
        assertEq(expected, actual);
    }
}
