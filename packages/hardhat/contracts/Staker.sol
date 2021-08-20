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
  bool public openForWithdraw = false;

  constructor(address _externalAddress) {
    exampleExternalContract = ExampleExternalContract(_externalAddress);
    deadline = block.timestamp + 30 seconds;
  } 

  modifier deadlinePassed() {
      require(block.timestamp <= deadline, "cannot deposit funds after the deadline has passed!");
      _;
  }

  function getStakedAmount(address _user) public view onlyOwner returns (uint) {
      return stakedAmounts[_user];
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint)` event and emit it for the frontend <List/> display )
  function stake() public payable {
      require(block.timestamp <= deadline, "cannot deposit funds after the deadline has passed!");
      stakedAmounts[msg.sender] += msg.value;
      emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public deadlinePassed {
      if (address(this).balance > threshold) {
        exampleExternalContract.complete{value: address(this).balance}();
      } else {
        openForWithdraw = true;
      }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw(uint _amount) public payable {
      // if time passed and threshold not met, allow anyone to call withdraw
      require(block.timestamp > deadline, 'must wait until the deadline has passed');
      if (address(this).balance <= threshold) {
          openForWithdraw = true;
      }
      require(openForWithdraw == true, 'minimum threshold met, cannot withdraw');
      require(_amount <=stakedAmounts[msg.sender]);
      stakedAmounts[msg.sender] -= _amount;
      (bool success, ) = payable(msg.sender).call{value: _amount}("");
      require(success, "transfer failed");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint) {
      if (block.timestamp > deadline) {
        return 0;
      } else {
        return deadline - block.timestamp;
      }
  }
}
