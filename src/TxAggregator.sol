pragma solidity ^0.6.7;

contract TxAggregator {

  struct Check {
    address payee;
    uint256 value;
    bool ingested
  }

  function submit(Check[] calldata checks) {
    for(uint256 i = 0; i < checks.length; i++) {
      Check memory check = checks[i];
  }

  event Deposit(address indexed payee, uint256 value);

  function deposit() payable external {
    emit Deposit(msg.sender, msg.value);
  }
}
