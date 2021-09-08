// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";


contract Staker is Ownable {

  ExampleExternalContract private exampleExternalContract;
  event Stake(address _user, uint _amount);
  mapping(address => uint) private stakedAmounts;
  uint public deadline; 
  uint public constant threshold = 1 ether;

  constructor(address _externalAddress) {
    exampleExternalContract = ExampleExternalContract(_externalAddress);
    deadline = block.timestamp + 30 seconds;
  } 

  modifier deadlinePassed() {
      require(block.timestamp >= deadline, "cannot perform this action, deadline HAS NOT passed!"); 
      _;
  }

  modifier deadlineNotPassed() {
      require(block.timestamp < deadline, "cannot perform this action, deadline HAS passed!");
      _;
  }

  modifier notCompleted() {
      require(exampleExternalContract.completed() == true,
              "cannot perform this action, exteral contract is not completed!");
      _;
  }

  function getStakedAmount(address _user) public view onlyOwner returns (uint) {
      return stakedAmounts[_user];
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint)` event and emit it for the frontend <List/> display )
  function stake() public payable deadlineNotPassed {
      stakedAmounts[msg.sender] += msg.value;
      emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public deadlinePassed notCompleted {
      require(address(this).balance > 0, "nothing to trasfer!");
      require(address(this).balance >= threshold, "staking did not exceed the threshold!");
      exampleExternalContract.complete{value: address(this).balance}();
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw(address _address) public payable deadlinePassed notCompleted {
      // if time passed and threshold not met, allow anyone to call withdraw
      require(_address == msg.sender, "can't take someone else's money my dude!");
      require(stakedAmounts[_address] > 0, "nothing to witdraw!");
      uint _amount = stakedAmounts[_address];
      stakedAmounts[_address] -= _amount;
      (bool success, ) = payable(_address).call{value: _amount}("");
      require(success, "transfer failed");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint) {
      if (block.timestamp >= deadline) {
        return 0;
      } else {
        return deadline - block.timestamp;
      }
  }
}
