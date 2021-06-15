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


            bytes32 left
         = 0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes32 hLeft = keccak256(abi.encodePacked(left));

        bytes32 leaf = keccak256(
            abi.encodePacked(token, address(this), amount)
        );
        bytes32 root = keccak256(abi.encodePacked(hLeft, leaf));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = hLeft;

        hon.deposit(proof, tokenAddr, amount);
        assertEq(root, hon.root());
    }
}
