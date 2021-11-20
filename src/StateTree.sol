pragma solidity ^0.8.6;

library StateTree {
    uint8 constant DEPTH = 8;

	function get(uint8 level) internal pure returns (bytes32) {
        bytes32[DEPTH+1] memory hashes;
        hashes[
            0
        ] = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
        hashes[
            1
        ] = 0x633dc4d7da7256660a892f8f1604a44b5432649cc8ec5cb3ced4c4e6ac94dd1d;
        hashes[
            2
        ] = 0x890740a8eb06ce9be422cb8da5cdafc2b58c0a5e24036c578de2a433c828ff7d;
        hashes[
            3
        ] = 0x3b8ec09e026fdc305365dfc94e189a81b38c7597b3d941c279f042e8206e0bd8;
        hashes[
            4
        ] = 0xecd50eee38e386bd62be9bedb990706951b65fe053bd9d8a521af753d139e2da;
        hashes[
            5
        ] = 0xdefff6d330bb5403f63b14f33b578274160de3a50df4efecf0e0db73bcdd3da5;
        hashes[
            6
        ] = 0x617bdd11f7c0a11f49db22f629387a12da7596f9d1704d7465177c63d88ec7d7;
        hashes[
            7
        ] = 0x292c23a9aa1d8bea7e2435e555a4a60e379a5a35f3f452bae60121073fb6eead;
        hashes[
            8
        ] = 0xe1cea92ed99acdcb045a6726b2f87107e8a61620a232cf4d7d5b5766b3952e10;
        return hashes[level];
    }

    function empty() internal pure returns (bytes32) {
		return get(DEPTH);
    }

	function validate(
		bytes32[] memory _proofs,
      	uint8 _index,
      	bytes32 _leaf,
	 	bytes32 _expectedRoot
	) internal pure returns (bool) {
		bytes32 actualRoot = compute(_proofs, _index, _leaf);
		return (actualRoot == _expectedRoot);
	}

	function write(
		bytes32[] memory _proofs,
      	uint8 _index,
	 	bytes32 _nextLeaf,
      	bytes32 _prevLeaf,
		bytes32 _prevRoot
	) internal pure returns (bytes32) {
		require(
			validate(_proofs, _index, _prevLeaf, _prevRoot),
		  	"update proof not valid"
		);
		return compute(_proofs, _index, _nextLeaf);
	}

	function compute(
      bytes32[] memory _proofs,
      uint8 _index,
      bytes32 _leaf
    ) internal pure returns (bytes32) {
        require(_index <= 2**DEPTH, "_index can't be bigger than tree size");
		require(
			_proofs.length <= DEPTH,
			"_proof length can't be greater than tree depth"
		);
		bytes32 hash = _leaf;

     	for (uint8 i = 0; i < _proofs.length; i++) {
        	bytes32 proofElement = _proofs[i];

        	if (_index % 2 == 0) {
          		hash = keccak256(abi.encode(hash, proofElement));
        	} else {
         		hash = keccak256(abi.encode(proofElement, hash));
        	}

        	_index = _index / 2;
      	}
		return hash;
    }
}
