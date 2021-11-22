// @format
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "./StateTree.sol";

contract StateTreeTest is DSTest {
    function setUp() public {}

    function genMapVal(uint8 bufLength, uint8 index) public returns (uint8) {
        uint8 bytePos = (bufLength - 1) - (index / 8);
        return bytePos + 1 << (index % 8);
    }

    function runAllMapVals() public {
        uint8 bufLength = 1;
        genMapVal(bufLength, 0);
        genMapVal(bufLength, 1);
        genMapVal(bufLength, 2);
        genMapVal(bufLength, 3);
        genMapVal(bufLength, 4);
        genMapVal(bufLength, 5);
        genMapVal(bufLength, 6);
        genMapVal(bufLength, 7);
    }

    function testBitwiseProofBitGeneration() public {
        uint8 bufLength = 1;

        // eval pos 0
        uint8 value = genMapVal(bufLength, 0);
        value += genMapVal(bufLength, 4);
        assertEq(value % 2, 1);

        // eval pos 1
        value = value / 2;
        assertEq(value % 2, 0);

        // eval pos 2
        value = value / 2;
        assertEq(value % 2, 0);

        // eval pos 3
        value = value / 2;
        assertEq(value % 2, 0);

        // eval pos 4
        value = value / 2;
        assertEq(value % 2, 1);

        // eval pos 5
        value = value / 2;
        assertEq(value % 2, 0);

        // eval pos 6
        value = value / 2;
        assertEq(value % 2, 0);

        // eval pos 7
        value = value / 2;
        assertEq(value % 2, 0);
    }

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
		assertEq(StateTree.compute(proofs, 0, 0, LEAF_HASH), expectedRoot);
	}

	function testValidateEmpty() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32 expectedRoot = StateTree.empty();
		assertTrue(
			StateTree.validate(proofs, 0, 0, LEAF_HASH,
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

		assertEq(StateTree.compute(proofs, 0, 0, LEAF_HASH), expectedRoot);
	}

	function testWriteFirst() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 PREV_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 PREV_LEAF_HASH = keccak256(abi.encode(PREV_LEAF));

		bytes32 PREV_ROOT = StateTree.empty();
		bytes32 NEXT_ROOT = StateTree.write(proofs, 0, 0, NEXT_LEAF_HASH, PREV_LEAF_HASH, PREV_ROOT);

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
		bytes32 ROOT2 = StateTree.write(proofs, 0, 0, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT1);

        uint8 bits = genMapVal(1, 0);
		bytes32[] memory proofs1 = new bytes32[](1);
        proofs1[0] = NEXT_LEAF_HASH;
		bytes32 ROOT3 = StateTree.write(proofs1, bits, 1, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT2);
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

			uint8 bits;
            uint256 pointer = i;
            for(uint8 j = 0; j < DEPTH; j++) {
                if(pointer % 2 == 0) {
                    //proofs[j] = zeros[j];
                } else {
                	bits += genMapVal(1, j);
                    proofs[j] = ones[j];
                }
                pointer = pointer / 2;
            }

            prevRoot = StateTree.write(proofs, bits, i, LEAF_HASH, ZERO_LEAF_HASH, prevRoot);
        }

	}


	function testFillUp() public {
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
        for(uint256 i = 0; i < 5; i++) {
            bytes32[] memory proofs = new bytes32[](DEPTH);

            uint8 bits;
            if (i == 0) {
                bits = 0;
            } else if (i == 1) {
                bits = genMapVal(1, 0);
                proofs[0] = ones[0];
            } else if (i == 2) {
                bits = genMapVal(1, 1);
                proofs[1] = ones[1];
            } else if (i == 3) {
                bits = genMapVal(1, 0);
                bits += genMapVal(1, 1);
                proofs[0] = ones[0];
                proofs[1] = ones[1];
            } else if (i == 4) {
                bits = genMapVal(1, 2);
                proofs[2] = ones[2];
			}

		    prevRoot = StateTree.write(proofs, bits, i, LEAF_HASH, ZERO_LEAF_HASH, prevRoot);
        }
	}

    function testFailHijackingHash() public {
		bytes32[] memory proofs = new bytes32[](0);
        uint8 bits = genMapVal(1, 0);

	    bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000001337;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));
		bytes32 ZERO_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
		bytes32 ZERO_LEAF_HASH = keccak256(abi.encode(ZERO_LEAF));

	    bytes32 newRoot = StateTree.write(proofs, bits, 0, LEAF_HASH, ZERO_LEAF_HASH, ZERO_LEAF_HASH);
        assertEq(newRoot, LEAF_HASH);
    }
}
