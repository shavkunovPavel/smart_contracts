pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol';
import "zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

import './YouMeeWaves.sol';
import './YouMeeRestricted.sol';

contract YouMeeRefund is YouMeeWaves, YouMeeRestricted, RefundableCrowdsale {

  function YouMeeRefund(uint256 _goal) RefundableCrowdsale(_goal) {}

  function _forwardFunds() internal {
    if (isInPreIcoWithBorder()) {
      wallet.transfer(msg.value);
      return;
    }
    super._forwardFunds();
  }

  function finalization() internal {
    mintTokenForTeam();

    if (PausableToken(token).paused()) {
      PausableToken(token).unpause();
    }

    MintableToken(token).finishMinting();

    super.finalization();
  }
}