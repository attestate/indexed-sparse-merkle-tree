// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "./StateTree.sol";

contract StateTreeTest is DSTest {
    function setUp() public {}

    function testGasOfCompute() public {
		bytes32[] memory proofs = new bytes32[](8);

        uint startGas = gasleft();
	    bytes32 root = StateTree.compute(proofs);
        uint endGas = gasleft();

        assertEq(root, 0);
        emit log_named_uint("gas calling compute()", startGas - endGas);
    }


    function testGettingZero() public {
        bytes32 empty = StateTree.empty();
		assertEq(empty, 0);
    }

	function testValidateEmpty() public {
		bytes32[] memory proofs = new bytes32[](8);

		bytes32 expectedRoot = StateTree.empty();
		assertTrue(StateTree.validate(proofs, expectedRoot));
	}

	function testComputeInsertFirst() public {
		bytes32[] memory proofs = new bytes32[](8);

		bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));
        proofs[0] = LEAF_HASH;

		bytes32 expectedRoot = LEAF_HASH;
     	for (uint256 i = 1; i < DEPTH; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, 0));
		}

		assertEq(StateTree.compute(proofs), expectedRoot);
	}

	function testWriteFirst() public {
		bytes32[] memory proofs = new bytes32[](8);
		bytes32[] memory overwrite = new bytes32[](2);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));
        overwrite[0] = NEXT_LEAF_HASH;

		bytes32 PREV_ROOT = StateTree.empty();
        uint startGas = gasleft();
		bytes32 NEXT_ROOT = StateTree.write(proofs, overwrite, PREV_ROOT);
        uint endGas = gasleft();
        emit log_named_uint("gas calling write()", startGas - endGas);

		bytes32 expectedRoot = NEXT_LEAF_HASH;
     	for (uint256 i = 1; i < DEPTH; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, 0));
		}
		assertEq(NEXT_ROOT, expectedRoot);
	}

	function testWriteThree() public {
		bytes32[] memory proofs = new bytes32[](8);
		bytes32[] memory overwrite = new bytes32[](2);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));
        overwrite[0] = NEXT_LEAF_HASH;

		bytes32 ROOT1 = StateTree.empty();
		bytes32 ROOT2 = StateTree.write(proofs, overwrite, ROOT1);

        bytes32 expectedRoot = NEXT_LEAF_HASH;
     	for (uint256 i = 1; i < DEPTH; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, 0));
		}
		assertEq(ROOT2, expectedRoot);

		bytes32[] memory proofs2 = new bytes32[](8);
        proofs2[0] = NEXT_LEAF_HASH;
		bytes32[] memory overwrite2 = new bytes32[](2);
        overwrite2[0] = NEXT_LEAF_HASH;
        overwrite2[1] = NEXT_LEAF_HASH;
		bytes32 ROOT3 = StateTree.write(proofs2, overwrite2, ROOT2);

        bytes32 expectedRoot2 = keccak256(abi.encode(NEXT_LEAF_HASH, NEXT_LEAF_HASH));
        for(uint256 i = 2; i < DEPTH; i++) {
            expectedRoot2 = keccak256(abi.encode(expectedRoot2, 0));
        }
		assertEq(ROOT3, expectedRoot2);

		bytes32[] memory proofs3 = new bytes32[](7);
        proofs3[0] = keccak256(abi.encode(NEXT_LEAF_HASH, NEXT_LEAF_HASH));
		assertTrue(StateTree.validate(proofs3, ROOT3));

		bytes32[] memory overwrite3 = new bytes32[](2);
		overwrite3[0] = proofs3[0];
        overwrite3[1] = keccak256(abi.encode(NEXT_LEAF_HASH, 0));
		StateTree.write(proofs3, overwrite3, ROOT3);
	}

   function testValidateAll() public {
        bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
        bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32[] memory ones = new bytes32[](DEPTH);
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
            bytes32[] memory proofs = new bytes32[](8);

			uint256 p = i;
			uint256 d = 0;
			while(p != 0) {
				if (p % 2 != 0) {
					proofs[d] = ones[d];
				}

				p /= 2;
				d += 1;
			}

            StateTree.validate(proofs, prevRoot);
			bytes32 newRoot = StateTree.compute(proofs);
			prevRoot = newRoot;
        }
    }

   function testWriteAll() public {
        bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
        bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32[] memory ones = new bytes32[](DEPTH);
        ones[0] = LEAF_HASH;
        ones[1] = keccak256(abi.encode(ones[0], ones[0]));
        ones[2] = keccak256(abi.encode(ones[1], ones[1]));
        ones[3] = keccak256(abi.encode(ones[2], ones[2]));
        ones[4] = keccak256(abi.encode(ones[3], ones[3]));
        ones[5] = keccak256(abi.encode(ones[4], ones[4]));
        ones[6] = keccak256(abi.encode(ones[5], ones[5]));
        ones[7] = keccak256(abi.encode(ones[6], ones[6]));

		bytes32 prevRoot = StateTree.empty();
        //for(uint256 i = 0; i < (2**DEPTH)-1; i++) {
        for(uint256 i = 0; i < 4; i++) {
            bytes32[] memory proofs = new bytes32[](8);
            bytes32[] memory overwrite = new bytes32[](2);

			uint256 p = i;
			uint256 d = 0;
			while(p != 0) {
				if (p % 2 == 1) {
					proofs[d] = ones[d];
				}

				p /= 2;
				d += 1;
			}

			if (i == 0) {
				assertEq(proofs[0], 0);
				assertEq(proofs[1], 0);
				overwrite[0] = LEAF_HASH;
			} else if (i == 1) {
				assertEq(proofs[0], LEAF_HASH);
				assertEq(proofs[1], 0);
				overwrite[0] = proofs[0];
				overwrite[1] = LEAF_HASH;
			} else if (i == 2) {
				assertEq(prevRoot, 0x7605c12dd7ba63a76312ebe20bcab106e02e3ef3db29bb11167883778be84915); 
				assertEq(proofs[0], 0);
				assertEq(proofs[1], ones[1]);
				overwrite[0] = LEAF_HASH;
				overwrite[1] = 0;
			} else if (i == 3) {
				overwrite[0] = LEAF_HASH;
				overwrite[1] = LEAF_HASH;
			}

			prevRoot = StateTree.write(proofs, overwrite, prevRoot);
        }
    }

    //function testFailHijackingHash() public {
	//	bytes32[] memory proofs = new bytes32[](0);
    //    uint8 bits = StateTree.bitmap(0);

	//    bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000001337;
	//	bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));
	//	bytes32 ZERO_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
	//	bytes32 ZERO_LEAF_HASH = keccak256(abi.encode(ZERO_LEAF));

	//    bytes32 newRoot = StateTree.write(proofs, bits, 0, LEAF_HASH, ZERO_LEAF_HASH, ZERO_LEAF_HASH);
    //    assertEq(newRoot, LEAF_HASH);
    //}

	//function testUpdatingFirstEntryAfterAdditionalWrite() public {
	//	bytes32[] memory proofs = new bytes32[](0);

	//	bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
	//	bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

	//	bytes32 PREV_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000000;
	//	bytes32 PREV_LEAF_HASH = keccak256(abi.encode(PREV_LEAF));

	//	bytes32 ROOT1 = StateTree.empty();
	//	bytes32 ROOT2 = StateTree.write(proofs, 0, 0, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT1);

    //    uint8 bits = StateTree.bitmap(0);
	//	bytes32[] memory proofs1 = new bytes32[](1);
    //    proofs1[0] = NEXT_LEAF_HASH;
	//	bytes32 ROOT3 = StateTree.write(proofs1, bits, 1, NEXT_LEAF_HASH, PREV_LEAF_HASH, ROOT2);

	//	bytes32 UPDATE_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000002;
	//	bytes32 UPDATE_LEAF_HASH = keccak256(abi.encode(UPDATE_LEAF));
    //    uint8 bits2 = StateTree.bitmap(0);
	//	bytes32[] memory proofs2 = new bytes32[](1);
    //    proofs2[0] = NEXT_LEAF_HASH;
	//	bytes32 ROOT4 = StateTree.write(proofs2, bits2, 0, UPDATE_LEAF_HASH, proofs2[0], ROOT3);
	//}
}
