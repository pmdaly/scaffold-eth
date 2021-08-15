pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  event Stake(address _user, uint256 _amount);
  mapping(address => uint256) public stakedAmounts;
  uint256 public deadline; 
  uint256 public constant threshold = 1 ether;

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = now + 30 seconds;
  } 

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
      require(msg.value > 0, 'can only deposit positive amounts bruh!');
      stakedAmounts[msg.sender] += msg.value;
      emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {
      // require condition
      require(now >= deadline, 'must wait until the deadline has passed!');
      console.log('executing...');
  }
 

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public {
      // if time passed and threshold not met, allow anyone to call withdraw
      require(now >= deadline, 'must wait until the deadline has passed');
      require(address(this).balance < threshold, 'minimum threshold met, cannot withdraw');
      console.log('withdrawing...');
  }



  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
      console.log(deadline - now);
      if (now > deadline) {
        return 0;
      } else {
        return deadline - now;
      }
  }

}
