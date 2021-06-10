pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./TxAggregator.sol";

contract TxAggregatorTest is DSTest {
    TxAggregator aggregator;

    function setUp() public {
        aggregator = new TxAggregator();
    }
}
