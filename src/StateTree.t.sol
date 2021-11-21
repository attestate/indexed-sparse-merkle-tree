pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "./StateTree.sol";

contract StateTreeTest is DSTest {
    function setUp() public {}

    function testGetHash() public {
        bytes32 hash = StateTree.get(0);
		assertEq(hash, 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563);
    }

    function testGettingZero() public {
        bytes32 empty = StateTree.empty();
		assertEq(empty, 0xe1cea92ed99acdcb045a6726b2f87107e8a61620a232cf4d7d5b5766b3952e10);
    }

	function testComputeEmpty() public {
		uint8 DEPTH = 8;
		bytes32[] memory proofs = new bytes32[](8);
     	for (uint8 i = 0; i < DEPTH; i++) {
			proofs[i] = StateTree.get(i);
		}

		bytes32 expectedRoot = StateTree.empty();
		assertEq(StateTree.compute(proofs, uint8(0), proofs[0]), expectedRoot);
	}

	function testValidateEmpty() public {
		uint8 DEPTH = 8;
		bytes32[] memory proofs = new bytes32[](8);
     	for (uint8 i = 0; i < DEPTH; i++) {
			proofs[i] = StateTree.get(i);
		}

		bytes32 expectedRoot = StateTree.empty();
		assertTrue(
			StateTree.validate(proofs, uint8(0), proofs[0],
			expectedRoot
		));
	}


	function testComputeInsertFirst() public {
		uint8 DEPTH = 8;
		bytes32[] memory proofs = new bytes32[](DEPTH);
     	for (uint8 i = 0; i < proofs.length; i++) {
			proofs[i] = StateTree.get(i+1);
		}

		bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32 expectedRoot = LEAF_HASH;
     	for (uint8 i = 0; i < proofs.length; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, proofs[i]));
		}


		assertEq(StateTree.compute(proofs, uint8(0), LEAF_HASH), expectedRoot);
	}

	function testWriteFirst() public {
		uint8 DEPTH = 8;
		bytes32[] memory proofs = new bytes32[](DEPTH);
     	for (uint8 i = 0; i < proofs.length; i++) {
			proofs[i] = StateTree.get(i);
		}

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 PREV_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 PREV_LEAF_HASH = keccak256(abi.encode(PREV_LEAF));

		bytes32 PREV_ROOT = StateTree.empty();
		bytes32 NEXT_ROOT = StateTree.write(proofs, uint8(0), NEXT_LEAF_HASH, PREV_LEAF_HASH, PREV_ROOT);

		bytes32 expectedRoot = NEXT_LEAF_HASH;
     	for (uint8 i = 0; i < proofs.length; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, proofs[i]));
		}
		assertEq(NEXT_ROOT, expectedRoot);
	}

	function testFillUp() public {
		uint8 DEPTH = 8;

	    bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));
		bytes32 ZERO_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 ZERO_LEAF_HASH = keccak256(abi.encode(ZERO_LEAF));

        bytes32[] memory zeros = new bytes32[](DEPTH);
        bytes32 hashZeros = ZERO_LEAF_HASH;
        zeros[0] = hashZeros;
        for(uint8 n = 1; n < DEPTH; n++) {
            hashZeros = keccak256(abi.encode(hashZeros, hashZeros));
            zeros[n] = hashZeros;
        }

        bytes32[] memory ones = new bytes32[](DEPTH);
        bytes32 hashOnes = LEAF_HASH;
        ones[0] = hashOnes;
        for(uint8 n = 1; n < DEPTH; n++) {
            hashOnes = keccak256(abi.encode(hashOnes, hashOnes));
            ones[n] = hashOnes;
        }

        bytes32 prevRoot = StateTree.empty();
        for(uint8 i = 0; i < (2**DEPTH)-1; i++) {
		    bytes32[] memory proofs = new bytes32[](DEPTH);

            uint8 pointer = i;
            for(uint j = 0; j < DEPTH; j++) {
                if(pointer % 2 == 0) {
                    proofs[j] = zeros[j];
                } else {
                    proofs[j] = ones[j];
                }
                pointer = pointer / 2;
            }

		    prevRoot = StateTree.write(proofs, i, LEAF_HASH, ZERO_LEAF_HASH, prevRoot);
        }
	}

    function testFailHijackingHash() public {
		bytes32[] memory proofs = new bytes32[](0);

	    bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000001337;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));
		bytes32 ZERO_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 ZERO_LEAF_HASH = keccak256(abi.encode(ZERO_LEAF));

	    bytes32 newRoot = StateTree.write(proofs, 0, LEAF_HASH, ZERO_LEAF_HASH, ZERO_LEAF_HASH);
        assertEq(newRoot, LEAF_HASH);
    }
}
