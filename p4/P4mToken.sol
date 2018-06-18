pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';

contract P4mToken is MintableToken {
  string public constant name = "P4ME Token";
  string public constant symbol = "PMETOK";
  uint32 public constant decimals = 18;

  /* Dividends */
  address public constant dividendWalletOwner = 0x14e451c65e0ce4A981e34025E93C770606a8FC20;

  uint256 public totalReward;
  uint256 public lastDivideRewardTime;

  struct TokenHolder {
    uint256 balance;
    uint256 balanceUpdateTime;
    uint256 rewardWithdrawTime;
  }

  mapping(address => TokenHolder) public holders;
  /* /Dividends */

  event Burn(address indexed burner, uint256 value);

  function burn(address from, uint256 _value) onlyOwner public {
    require(_value <= balances[from]);

    address burner = from;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
  }

  /**
   * Dividends
   */
  modifier onlyDividendWalletOwner() {
    require(msg.sender == dividendWalletOwner);
    _;
  }

  function () external payable onlyDividendWalletOwner {}

  function withdraw() public onlyDividendWalletOwner {
    dividendWalletOwner.transfer(this.balance);
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balanceChanges(msg.sender);
    balanceChanges(_to);

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balanceChanges(_from);
    balanceChanges(_to);

    return super.transferFrom(_from, _to, _value);
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    balanceChanges(_to);

    return super.mint(_to, _amount);
  }

  function balanceChanges(address _who) internal {
    if (holders[_who].balanceUpdateTime <= lastDivideRewardTime) {
      holders[_who].balanceUpdateTime = now;
      holders[_who].balance = balanceOf(_who);
    }
  }

  function divideUpReward() public onlyDividendWalletOwner {
    require(this.balance > 0);
    require((lastDivideRewardTime + 30 days) < now);

    lastDivideRewardTime = now;
    totalReward = this.balance;
  }

  function reward() view public returns (uint256) {
    if (holders[msg.sender].rewardWithdrawTime >= lastDivideRewardTime) {
      return 0;
    }
    uint256 _balance;
    if (holders[msg.sender].balanceUpdateTime <= lastDivideRewardTime) {
      _balance = balanceOf(msg.sender);
    } else {
      _balance = holders[msg.sender].balance;
    }
    return totalReward.mul(_balance).div(totalSupply_);
  }

  function withdrawReward() public returns (uint256) {
    uint256 value = reward();
    if (value == 0) {
      return 0;
    }
    if (!msg.sender.send(value)) {
      return 0;
    }
    if (balanceOf(msg.sender) == 0) {
      delete holders[msg.sender];
    } else {
      holders[msg.sender].rewardWithdrawTime = now;
    }
    return value;
  }

  function dividendsBalanceUpdateTime() view public returns (uint256) {
    return holders[msg.sender].balanceUpdateTime;
  }

  function dividendsRewardWithdrawTime() view public returns (uint256) {
    return holders[msg.sender].rewardWithdrawTime;
  }

  function dividendsBalance() view public returns (uint256) {
    return holders[msg.sender].balance;
  }
}
