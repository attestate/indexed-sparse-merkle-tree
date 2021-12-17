// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

uint256 constant SIZE = 255;
uint256 constant DEPTH = 8;

library StateTree {
    function empty() internal pure returns (bytes32) {
		return 0;
    }

	function validate(
		bytes32[] memory _proofs,
	 	bytes32 _expectedRoot
	) internal pure returns (bool) {
		return (compute(_proofs) == _expectedRoot);
	}

	function write(
		bytes32[] memory _proofs,
        bytes32[] memory _overwrite,
		bytes32 _prevRoot
	) internal pure returns (bytes32) {
		require(
			validate(_proofs, _prevRoot),
		  	"update proof not valid"
		);
        _proofs[0] = _overwrite[0];
        _proofs[1] = _overwrite[1];
		return compute(_proofs);
	}

	function compute(
      bytes32[] memory _proofs
    ) internal pure returns (bytes32) {
        require(_proofs.length <= DEPTH, "Invalid _proofs length");

        bytes32 res = _proofs[0];
        for(uint256 i = 1; i < _proofs.length; i++) {
          if (res == 0 && _proofs[i] == 0) {
              res = 0;
          } else {
              res = keccak256(abi.encode(res, _proofs[i]));
          }
        }

		return res;
    }
}
