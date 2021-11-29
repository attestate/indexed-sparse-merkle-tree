// @format
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
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32 expectedRoot = StateTree.empty();
		assertEq(StateTree.compute(proofs, 0, LEAF_HASH), expectedRoot);
	}

	function testValidateEmpty() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32 expectedRoot = StateTree.empty();
		assertTrue(
			StateTree.validate(proofs, 0, LEAF_HASH,
			expectedRoot
		));
	}

	function testComputeInsertFirst() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32 expectedRoot = LEAF_HASH;
     	for (uint256 i = 0; i < StateTree.DEPTH; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, StateTree.get(i)));
		}

		assertEq(StateTree.compute(proofs, 0, LEAF_HASH), expectedRoot);
	}

	function testWriteFirst() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 PREV_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 PREV_LEAF_HASH = keccak256(abi.encode(PREV_LEAF));

		bytes32 PREV_ROOT = StateTree.empty();
		bytes32 NEXT_ROOT = StateTree.write(proofs, 0, NEXT_LEAF_HASH, PREV_LEAF_HASH, PREV_ROOT);

		bytes32 expectedRoot = NEXT_LEAF_HASH;
     	for (uint256 i = 0; i < StateTree.DEPTH; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, StateTree.get(i)));
		}
		assertEq(NEXT_ROOT, expectedRoot);
	}

	function testWriteTwo() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 PREV_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 PREV_LEAF_HASH = keccak256(abi.encode(PREV_LEAF));

		bytes32 ROOT1 = StateTree.empty();
		bytes32 ROOT2 = StateTree.write(proofs, 0, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT1);

		bytes32[] memory proofs1 = new bytes32[](1);
        proofs1[0] = NEXT_LEAF_HASH;
		bytes32 ROOT3 = StateTree.write(proofs1, 1, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT2);
	}

	function testFillUpTree() public {
		uint256 DEPTH = StateTree.DEPTH;
	    bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));
		bytes32 ZERO_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 ZERO_LEAF_HASH = keccak256(abi.encode(ZERO_LEAF));

        bytes32[] memory ones = new bytes32[](DEPTH);
        bytes32 hashOnes = LEAF_HASH;
        ones[0] = LEAF_HASH;
        ones[1] = keccak256(abi.encode(ones[0], ones[0]));
        ones[2] = keccak256(abi.encode(ones[1], ones[1]));
        ones[3] = keccak256(abi.encode(ones[2], ones[2]));
        ones[4] = keccak256(abi.encode(ones[3], ones[3]));
        ones[5] = keccak256(abi.encode(ones[4], ones[4]));
        ones[6] = keccak256(abi.encode(ones[5], ones[5]));
        ones[7] = keccak256(abi.encode(ones[6], ones[6]));

 		bytes32 prevRoot = StateTree.empty();
        for(uint256 i = 0; i < (2**DEPTH)-1; i++) {
            bytes32[] memory proofs = new bytes32[](DEPTH);

            uint256 pointer = i;
            for(uint8 j = 0; j < DEPTH; j++) {
                if(pointer % 2 == 0) {
                    //proofs[j] = zeros[j];
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

	function testUpdatingFirstEntryAfterAdditionalWrite() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 PREV_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 PREV_LEAF_HASH = keccak256(abi.encode(PREV_LEAF));

		bytes32 ROOT1 = StateTree.empty();
		bytes32 ROOT2 = StateTree.write(proofs, 0, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT1);

		bytes32[] memory proofs1 = new bytes32[](1);
        proofs1[0] = NEXT_LEAF_HASH;
		bytes32 ROOT3 = StateTree.write(proofs1, 1, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT2);
        // NOTE: Now, we'd like to go back to leaf of index 0 and update it's
        // value e.g. from "1" to "2". But since the sparse merkle tree of this
        // version assumes an "append-only" type of update scheme by implicitly using
        // the key's position to chose zero-hashes, we can't.

		bytes32 UPDATE_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000002;
		bytes32 UPDATE_LEAF_HASH = keccak256(abi.encode(UPDATE_LEAF));
		bytes32[] memory proofs2 = new bytes32[](1);
        proofs2[0] = NEXT_LEAF_HASH;
		bytes32 ROOT4 = StateTree.write(proofs, 0, UPDATE_LEAF_HASH, NEXT_LEAF_HASH, ROOT3);
	}
}
