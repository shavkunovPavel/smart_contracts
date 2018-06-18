pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import './P4mToken.sol';

import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/Crowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol';

contract P4mCrowdsale is CappedCrowdsale, FinalizableCrowdsale {

  uint256 private constant presaleDuration = 5;
  uint256 private constant gapDuration = 2;

  uint256 private constant timeDiff = 5 hours;
  uint256 private constant _startTime = 1518102840 - timeDiff; // start ICO
  uint256 private constant _endTime = 1518116400 - timeDiff; // end ICO

  uint256 public thisRate = 450;
  uint256 private constant _cap = 1000 ether;

  uint256 public constant presaleStartTime = _startTime;
  uint256 public constant presaleEndTime = presaleStartTime + presaleDuration;
  uint256 public constant presaleCap = 100 ether;

  uint256 public constant gapStartTime = presaleEndTime;
  uint256 public constant gapEndTime = gapStartTime + gapDuration;

  uint256 public constant restrictedPercent = 25;
  address public constant restrictedWallet = 0x79887aa494Ab3D04F63585a71F06dB6d9871019A;

  modifier onlyWallet() {
    require(msg.sender == wallet);
    _;
  }

  function P4mCrowdsale(address _wallet) public
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    Crowdsale(_startTime, _endTime, thisRate, _wallet)
  {}

  function createTokenContract() internal returns (MintableToken) {
    return new P4mToken();
  }

  function buyTokens(address beneficiary) public payable {
    rate = getRate();
    super.buyTokens(beneficiary);
  }

  function getRate() internal view returns (uint256) {
    if (inPresale()) {
      return thisRate.mul(2);
    }

    return thisRate;
  }

  function changeRate(uint256 newRate) public onlyWallet {
    require(newRate > 0);
    thisRate = newRate;
  }

  function validPurchase() internal view returns (bool) {
    bool withinCap = true;
    if (inPresale()) {
      withinCap = weiRaised.add(msg.value) <= presaleCap;
    }
    bool stopWhenGap = inGap();

    return super.validPurchase() && withinCap && !stopWhenGap;
  }

  function finalization() internal {
    uint256 tokens = getRestrictedTokens();
    token.mint(restrictedWallet, tokens);

    token.finishMinting();
    super.finalization();
  }

  function getRestrictedTokens() view public returns (uint256) {
    uint256 issuedTokenSupply = token.totalSupply();
    uint256 restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
    return restrictedTokens;
  }

  function burn(uint256 _value) onlyOwner public {
    P4mToken(token).burn(owner, _value);
  }

  function inPresale() public view returns (bool) {
    return (now >= presaleStartTime && now <= presaleEndTime);
  }

  function inGap() public view returns (bool) {
    return (now >= gapStartTime && now <= gapEndTime);
  }
}
