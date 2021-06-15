// @format
pragma solidity ^0.6.7;

import "ds-token/token.sol";
import "./StateTree.sol";

contract Honeybatcher {
    StateTree public tree;
    bytes32 public root;

    constructor() public {
        tree = new StateTree();
        root = tree.root();
    }

    function deposit(
        bytes32[] calldata proof,
        address token,
        uint256 amount
    ) external {
        DSToken(token).transferFrom(msg.sender, address(this), amount);
        bytes32 leaf = keccak256(abi.encodePacked(token, msg.sender, amount));
        tree.writeInsertion(proof, leaf);
        root = tree.root();
    }

    function withdraw(
        bytes32[] calldata proof,
        address token,
        uint256 amount
    ) external {
        bytes32 leaf =  keccak256(abi.encodePacked(token, msg.sender, amount));
        bytes32 actual = tree.probeInsertion(proof, leaf);
        require(actual == root);

        uint256 newAmount = 0;
        tree.writeInsertion(
            proof,
            keccak256(abi.encodePacked(token, msg.sender, newAmount))
        );
        root = tree.root();
        DSToken(token).transfer(msg.sender, amount);
    }
}
