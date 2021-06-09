pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./TxAggregator.sol";

contract TxAggregatorTest is DSTest {
    TxAggregator aggregator;

    function setUp() public {
        aggregator = new TxAggregator();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
