pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

import "./YouMeeRefund.sol";
import "./YouMeeWhiteList.sol";

contract YouMeeCrowdsale is YouMeeRefund, YouMeeWhiteList, MintedCrowdsale {

  function YouMeeCrowdsale(
    uint256 _openingTime, uint256 _closingTime,
    uint256 _rate, address _wallet, MintableToken _token,
    uint256 _cap, uint256 _softCap
  ) public
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    CappedCrowdsale(_cap)
    YouMeeRefund(_softCap)
  {
    require(_softCap <= _cap);
  }

  /** Allows the current owner to transfer control of the contracts token to a newOwner
   * @param _newOwner The address to transfer ownership to
   */
  function transferTokenOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    MintableToken(token).transferOwnership(_newOwner);
  }

}
