pragma solidity ^0.6.7;

library StateTree {
    function getEmpty() internal pure returns (bytes32) {
        bytes32 zero
         = 0x0000000000000000000000000000000000000000000000000000000000000000;
        return keccak256(abi.encodePacked(zero));
    }

	// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9d5f77db9da0604ce0b25148898a94ae2c20d70f/contracts/utils/cryptography/MerkleProof.sol
    function compute(
        bytes32[] memory proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash;
    }
}
