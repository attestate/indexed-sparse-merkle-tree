pragma solidity ^0.6.7;

contract StateTree {
    bytes32 public root;

    constructor() public {
        bytes32 zero
         = 0x0000000000000000000000000000000000000000000000000000000000000000;
        root = keccak256(abi.encodePacked(zero));
    }

    function writeInsertion(bytes32[] calldata _proof, bytes calldata _leafData)
        external
    {
        bytes32 leaf = keccak256(_leafData);
        bytes32 newRoot = probeInsertion(_proof, leaf);
        root = newRoot;
    }

    function probeInsertion(bytes32[] memory _proof, bytes32 _leaf)
        internal
        pure
        returns (bytes32)
    {
        bytes32 computedHash = _leaf;

        for (uint256 i = 0; i < _proof.length; i++) {
            bytes32 proofElement = _proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        return computedHash;
    }
}
