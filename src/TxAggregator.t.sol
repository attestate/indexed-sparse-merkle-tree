pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./TxAggregator.sol";

contract TxAggregatorTest is DSTest {
    TxAggregator aggregator;

    function setUp() public {
        aggregator = new TxAggregator();
    }

    function test_deposit() public {
      (bool sent,) = address(aggregator).call{value: 1 ether}(
        abi.encodeWithSignature("deposit()")
      );
      assert(sent);
      assertEq(address(aggregator).balance, 1 ether);
    }
}
