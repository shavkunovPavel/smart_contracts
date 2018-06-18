pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

contract YouMeeCoin is MintableToken, PausableToken {
  string public constant name = "YouMee Coin";
  string public constant symbol = "YMC";
  uint32 public constant decimals = 18;

  mapping (address => uint256) private lockUntil;

  function canWalletTransfer(address addr) public view returns(bool) {
    return lockUntil[addr] < now;
  }

  // Checks whether it can transfer or otherwise throws.
  modifier canTransfer(address _sender) {
    require(canWalletTransfer(_sender));
    _;
  }

  function transfer(address _to, uint256 _value) public canTransfer(msg.sender) returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  // lock address from transfering until ..
  function lockTill(address addr, uint256 unlockTime) public onlyOwner {
    lockUntil[addr] = unlockTime;
  }

  function getTillTime(address addr) public view returns(uint256) {
    return lockUntil[addr];
  }
}
