pragma solidity ^0.6.7;

import "ds-test/test.sol";
import "ds-token/token.sol";

import "./Honeybatcher.sol";

contract UnsafeDepositToken {
    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public pure returns (bool) {
        return false;
    }
}

contract UnsafeWithdrawToken {
    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public pure returns (bool) {
        return true;
    }

    function transfer(address dst, uint256 wad) public pure returns (bool) {
        return false;
    }
}

contract HoneybatcherTest is DSTest {
    Honeybatcher hon;
    DSToken token;
    uint256 total;

    function setUp() public {
        hon = new Honeybatcher();
        token = new DSToken("T");
        total = 1;
    }

    function testIfDepositFailsWithInsufficientBalance() public {
        UnsafeDepositToken ut = new UnsafeDepositToken();
        bytes32 currentRoot = hon.root();
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = currentRoot;

        string memory expected = "hb-deposit-transferFrom-fail";
        string memory err;
        try hon.deposit(proof, address(ut), total) {} catch Error(
            string memory _err
        ) {
            err = _err;
        }
        assertEq(err, expected);
    }

    function testDeposit() public {
        token.mint(total);
        token.approve(address(hon), total);
        assertEq(token.allowance(address(this), address(hon)), total);
        bytes32 currentRoot = hon.root();
        bytes32 leaf = keccak256(abi.encodePacked(token, address(this), total));
        bytes32 root = keccak256(abi.encodePacked(currentRoot, leaf));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = currentRoot;

        hon.deposit(proof, address(token), total);
        assertEq(root, hon.root());
    }

    function testIfWithdrawFailsIfBalanceIsInsufficient() public {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = hon.root();

        string memory expected = "hb-withdraw-compute-fail";
        string memory err;
        try hon.withdraw(proof, address(token), 1337) {} catch Error(
            string memory _err
        ) {
            err = _err;
        }
        assertEq(err, expected);
    }

    function testIfWithdrawFailsIfStateTreeComputationYieldsIncorrectRoot()
        public
    {
        UnsafeWithdrawToken ut = new UnsafeWithdrawToken();
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = hon.root();

        hon.deposit(proof, address(ut), total);

        string memory expected = "hb-withdraw-transfer-fail";
        string memory err;
        try hon.withdraw(proof, address(ut), total) {} catch Error(
            string memory _err
        ) {
            err = _err;
        }
        assertEq(err, expected);
    }

    function testWithdraw() public {
        address tokenAddr = address(token);
        token.mint(total);
        token.approve(address(hon), total);
        bytes32 currentRoot = hon.root();

        bytes32 leaf = keccak256(abi.encodePacked(token, address(this), total));
        bytes32 root = keccak256(abi.encodePacked(currentRoot, leaf));
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = currentRoot;
        hon.deposit(proof, tokenAddr, total);
        assertEq(root, hon.root());

        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.balanceOf(address(hon)), 1);

        hon.withdraw(proof, tokenAddr, total);
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
