// SPDX-License-Identifier: GPL-3.0-only
// Copyright (c) Tim Daubenschütz.
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "./StateTree.sol";

contract StateTreeTest is DSTest {
    function setUp() public {}

    function testBitwiseProofBitGeneration() public {
        // eval pos 0
        uint8 value = StateTree.bitmap(0);
        value += StateTree.bitmap(4);
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

    function testGasCostEmpty() public {
        uint startGas = gasleft();
        bytes32 empty = StateTree.empty();
        uint endGas = gasleft();
        emit log_named_uint("empty()", startGas - endGas);
		assertEq(empty, 0);
    }

    function testGasCostCompute() public {
		bytes32[] memory proofs = new bytes32[](0);

        uint startGas = gasleft();
		StateTree.compute(proofs, 0, 0, 0);
        uint endGas = gasleft();
        emit log_named_uint("compute() best case", startGas - endGas);
    }

    function testGasCostValidate() public {
		bytes32[] memory proofs = new bytes32[](0);

        uint startGas = gasleft();
		StateTree.validate(proofs, 0, 0, 0, 0);
        uint endGas = gasleft();
        emit log_named_uint("validate() best case", startGas - endGas);
    }

	function testGasWrite() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 PREV_ROOT = StateTree.empty();
        uint startGas = gasleft();
		StateTree.write(proofs, 0, 0, NEXT_LEAF_HASH, 0, PREV_ROOT);
        uint endGas = gasleft();
        emit log_named_uint("write best case()", startGas - endGas);
	}

	function testComputeEmpty() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 expectedRoot = StateTree.empty();
		assertEq(StateTree.compute(proofs, 0, 0, 0), expectedRoot);
	}

	function testValidateEmpty() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 expectedRoot = StateTree.empty();
		assertTrue(StateTree.validate(proofs, 0, 0, 0, expectedRoot));
	}

	function testComputeInsertFirst() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

		bytes32 expectedRoot = LEAF_HASH;
     	for (uint256 i = 0; i < DEPTH; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, 0));
		}

		assertEq(StateTree.compute(proofs, 0, 0, LEAF_HASH), expectedRoot);
	}

	function testWriteFirst() public {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 PREV_ROOT = StateTree.empty();
		bytes32 NEXT_ROOT = StateTree.write(proofs, 0, 0, NEXT_LEAF_HASH, 0, PREV_ROOT);

		bytes32 expectedRoot = NEXT_LEAF_HASH;
     	for (uint256 i = 0; i < DEPTH; i++) {
			expectedRoot = keccak256(abi.encode(expectedRoot, 0));
		}
		assertEq(NEXT_ROOT, expectedRoot);
	}

	function testWriteTwo() public pure {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 ROOT1 = StateTree.empty();
		bytes32 ROOT2 = StateTree.write(proofs, 0, 0, NEXT_LEAF_HASH, 0, ROOT1);

        uint8 bits = StateTree.bitmap(0);
		bytes32[] memory proofs1 = new bytes32[](1);
        proofs1[0] = NEXT_LEAF_HASH;
		StateTree.write(proofs1, bits, 1, NEXT_LEAF_HASH, 0, ROOT2);
	}

	function testFillUpTree() public pure {
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
            bytes32[] memory proofs = new bytes32[](DEPTH);

			uint8 bits;
            uint256 pointer = i;
            for(uint8 j = 0; j < DEPTH; j++) {
                if(pointer % 2 == 0) {
                    //proofs[j] = zeros[j];
                } else {
                	bits += StateTree.bitmap(j);
                    proofs[j] = ones[j];
                }
                pointer = pointer / 2;
            }

            prevRoot = StateTree.write(proofs, bits, i, LEAF_HASH, 0, prevRoot);
        }

	}

    function testFailHijackingHash() public {
		bytes32[] memory proofs = new bytes32[](0);
        uint8 bits = StateTree.bitmap(0);

	    bytes32 LEAF = 0x0000000000000000000000000000000000000000000000000000000000001337;
		bytes32 LEAF_HASH = keccak256(abi.encode(LEAF));

	    bytes32 newRoot = StateTree.write(proofs, bits, 0, LEAF_HASH, 0, 0);
        assertEq(newRoot, LEAF_HASH);
    }

	function testUpdatingFirstEntryAfterAdditionalWrite() public pure {
		bytes32[] memory proofs = new bytes32[](0);

		bytes32 NEXT_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000001;
		bytes32 NEXT_LEAF_HASH = keccak256(abi.encode(NEXT_LEAF));

		bytes32 ROOT1 = StateTree.empty();
		bytes32 ROOT2 = StateTree.write(proofs, 0, 0, NEXT_LEAF_HASH, 0, ROOT1);

        uint8 bits = StateTree.bitmap(0);
		bytes32[] memory proofs1 = new bytes32[](1);
        proofs1[0] = NEXT_LEAF_HASH;
		bytes32 ROOT3 = StateTree.write(proofs1, bits, 1, NEXT_LEAF_HASH, 0, ROOT2);

		bytes32 UPDATE_LEAF = 0x0000000000000000000000000000000000000000000000000000000000000002;
		bytes32 UPDATE_LEAF_HASH = keccak256(abi.encode(UPDATE_LEAF));
        uint8 bits2 = StateTree.bitmap(0);
		bytes32[] memory proofs2 = new bytes32[](1);
        proofs2[0] = NEXT_LEAF_HASH;
		StateTree.write(proofs2, bits2, 0, UPDATE_LEAF_HASH, proofs2[0], ROOT3);
	}
}
