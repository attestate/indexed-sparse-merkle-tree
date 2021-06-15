pragma solidity ^0.6.7;

import "ds-test/test.sol";
import "./StateTree.sol";

contract ExposedStateTree is StateTree {
    function _probeInsertion(bytes32[] memory _proof, bytes32 _leaf)
        public
        pure
        returns (bytes32)
    {
        return probeInsertion(_proof, _leaf);
    }
}

contract StateTreeTest is DSTest {
    ExposedStateTree public tree;

    function setUp() public {
        tree = new ExposedStateTree();
    }

    function testInit() public {
        assertTrue(tree.root() != 0);
    }

    function testProbeRightInsertion() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = tree.root();


            bytes32 first
         = 0x0000000000000000000000000000000000000000000000000000000000000002;
        bytes32 fLeaf = keccak256(abi.encodePacked(first));
        bytes32 actual = tree._probeInsertion(proof, fLeaf);

        bytes32 expected = keccak256(abi.encodePacked(tree.root(), fLeaf));
        assertEq(expected, actual);
    }
}
