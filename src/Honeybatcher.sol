// @format
pragma solidity ^0.6.7;

import "ds-token/token.sol";
import "./StateTree.sol";

contract Honeybatcher {
    bytes32 public root;

    constructor() public {
        root = StateTree.getEmpty();
    }

    function deposit(
        bytes32[] calldata proof,
        address token,
        uint256 amount
    ) external {
        require(
            DSToken(token).transferFrom(msg.sender, address(this), amount),
            "hb-deposit-transferFrom-fail"
        );
        bytes32 leaf = keccak256(abi.encodePacked(token, msg.sender, amount));
        root = StateTree.compute(proof, leaf);
    }

    function withdraw(
        bytes32[] calldata proof,
        address token,
        uint256 amount
    ) external {
        bytes32 leaf = keccak256(abi.encodePacked(token, msg.sender, amount));
        bytes32 actual = StateTree.compute(proof, leaf);
        require(actual == root, "hb-withdraw-compute-fail");

        uint256 newAmount = 0;
        root = StateTree.compute(
            proof,
            keccak256(abi.encodePacked(token, msg.sender, newAmount))
        );
        require(
            DSToken(token).transfer(msg.sender, amount),
            "hb-withdraw-transfer-fail"
        );
    }
}
