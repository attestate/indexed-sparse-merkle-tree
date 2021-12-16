pragma solidity ^0.8.6;

function hashes(uint256 _level) pure returns (bytes32) {
  if(_level == 0) {
      return 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563;
  } else if(_level == 1) {
      return 0x633dc4d7da7256660a892f8f1604a44b5432649cc8ec5cb3ced4c4e6ac94dd1d;
  } else if(_level == 2) {
      return 0x890740a8eb06ce9be422cb8da5cdafc2b58c0a5e24036c578de2a433c828ff7d;
  } else if(_level == 3) {
      return 0x3b8ec09e026fdc305365dfc94e189a81b38c7597b3d941c279f042e8206e0bd8;
  } else if(_level == 4) {
      return 0xecd50eee38e386bd62be9bedb990706951b65fe053bd9d8a521af753d139e2da;
  } else if(_level == 5) {
      return 0xdefff6d330bb5403f63b14f33b578274160de3a50df4efecf0e0db73bcdd3da5;
  } else if(_level == 6) {
      return 0x617bdd11f7c0a11f49db22f629387a12da7596f9d1704d7465177c63d88ec7d7;
  } else if(_level == 7) {
      return 0x292c23a9aa1d8bea7e2435e555a4a60e379a5a35f3f452bae60121073fb6eead;
  } else if(_level == 8) {
      return 0xe1cea92ed99acdcb045a6726b2f87107e8a61620a232cf4d7d5b5766b3952e10;
  }
}

uint256 constant SIZE = 255;
uint256 constant BUFFER_LENGTH = 1;
uint256 constant DEPTH = 8;

library StateTree {
	function get(uint256 _level) internal pure returns (bytes32) {
		return hashes(_level);
    }

    function bitmap(uint256 index) internal pure returns (uint8) {
        uint8 bytePos = (uint8(BUFFER_LENGTH) - 1) - (uint8(index) >> 3);
        return bytePos + 1 << (uint8(index) % 8);
    }

    function empty() internal pure returns (bytes32) {
		return hashes(DEPTH);
    }

	function validate(
		bytes32[] memory _proofs,
        uint8 _bits,
      	uint256 _index,
      	bytes32 _leaf,
	 	bytes32 _expectedRoot
	) internal pure returns (bool) {
		return (compute(_proofs, _bits, _index, _leaf) == _expectedRoot);
	}

	function write(
		bytes32[] memory _proofs,
        uint8 _bits,
      	uint256 _index,
	 	bytes32 _nextLeaf,
      	bytes32 _prevLeaf,
		bytes32 _prevRoot
	) internal pure returns (bytes32) {
		require(
			validate(_proofs, _bits, _index, _prevLeaf, _prevRoot),
		  	"update proof not valid"
		);
		return compute(_proofs, _bits, _index, _nextLeaf);
	}

	function compute(
      bytes32[] memory _proofs,
      uint8 _bits,
      uint256 _index,
      bytes32 _leaf
    ) internal pure returns (bytes32) {
        require(_index < SIZE, "_index bigger than tree size");
        require(_proofs.length <= DEPTH, "Invalid _proofs length");

        proofElement = hashes(0);
        hash = keccak256(abi.encode(hash, proofElement));
        _bits = _bits >> 1;
        _index = _index >> 1;

        proofElement = _proofs[1];
        hash = keccak256(abi.encode(proofElement, hash));
        _bits = _bits >> 1;
        _index = _index >> 1;

        proofElement = hashes(2);
        hash = keccak256(abi.encode(hash, proofElement));
        _bits = _bits >> 1;
        _index = _index >> 1;

        proofElement = _proofs[3];
        hash = keccak256(abi.encode(proofElement, hash));
        _bits = _bits >> 1;
        _index = _index >> 1;

        proofElement = hashes(4);
        hash = keccak256(abi.encode(hash, proofElement));
        _bits = _bits >> 1;
        _index = _index >> 1;

        proofElement = _proofs[5];
        hash = keccak256(abi.encode(proofElement, hash));
        _bits = _bits >> 1;
        _index = _index >> 1;

        proofElement = hashes(6);
        hash = keccak256(abi.encode(hash, proofElement));
        _bits = _bits >> 1;
        _index = _index >> 1;

        proofElement = _proofs[7];
        hash = keccak256(abi.encode(proofElement, hash));
        _bits = _bits >> 1;
        _index = _index >> 1;
        
		    return hash;

    }
}
