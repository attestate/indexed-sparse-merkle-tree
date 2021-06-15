pragma solidity ^0.6.7;

import "ds-test/test.sol";
import "ds-token/token.sol";

import "./Honeybatcher.sol";

contract HoneybatcherTest is DSTest {
    Honeybatcher hon;
    DSToken token;

    function setUp() public {
        hon = new Honeybatcher();
        token = new DSToken("T");
    }

    function testDeposit() public {
        uint256 amount = 1;
        address tokenAddr = address(token);
        token.mint(amount);
        token.approve(address(hon), amount);
        bytes32 currentRoot = hon.root();

        bytes32 leaf = keccak256(
            abi.encodePacked(token, address(this), amount)
        );
        bytes32 root = keccak256(abi.encodePacked(currentRoot, leaf));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = currentRoot;

        hon.deposit(proof, tokenAddr, amount);
        assertEq(root, hon.root());
    }

    function testWithdraw() public {
        uint256 amount = 1;
        address tokenAddr = address(token);
        token.mint(amount);
        token.approve(address(hon), amount);
        bytes32 currentRoot = hon.root();

        bytes32 leaf = keccak256(
            abi.encodePacked(token, address(this), amount)
        );
        bytes32 root = keccak256(abi.encodePacked(currentRoot, leaf));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = currentRoot;
        hon.deposit(proof, tokenAddr, amount);
        assertEq(root, hon.root());

        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.balanceOf(address(hon)), 1);

        hon.withdraw(proof, tokenAddr, amount);
        uint256 newAmount = 0;
        bytes32 newLeaf = keccak256(
            abi.encodePacked(token, address(this), newAmount)
        );
        bytes32 newRoot = keccak256(abi.encodePacked(currentRoot, newLeaf));
        assertEq(newRoot, hon.root());
        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.balanceOf(address(hon)), 0);
    }
}
