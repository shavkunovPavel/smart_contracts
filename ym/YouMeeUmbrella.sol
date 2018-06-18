pragma solidity ^0.4.18;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./YouMeeOwnable.sol";

contract YouMeeUmbrella is YouMeeOwnable {
  using SafeMath for uint256;

  uint256 public constant divider = 1000;

  struct Umbrella {
    address owner;
    uint256 percent;
  }

  mapping(address => Umbrella) public umbrellaList;
  mapping(address => address[]) public holders;

  function withdraw(address _token) public onlyMaster {
    uint256 _am = ERC20(_token).balanceOf(this);
    if (_am > 0) {
      ERC20(_token).transfer(master, _am);
    }
  }

  function existUser(address _holder, address _user) public view returns(bool) {
    uint256 iMax = holders[_holder].length;
    for (uint256 i = 0; i < iMax; i++) {
      if (holders[_holder][i] == _user) {
        return true;
      }
    }
    return false;
  }

  function addUmbrella(address _umb, address _holder, uint256 _percent) public onlyMaster {
    require(_umb != address(0));
    require(_holder != address(0));

    umbrellaList[_umb] = Umbrella(_holder, _percent);
    if (!existUser(_holder, _umb)) {
      holders[_holder].push(_umb);
    }
    UmbrellaAdded(_umb, _holder, _percent);
  }

  function users(address _holder) public view returns(address[]) {
    return holders[_holder];
  }

  function doTransfer(address _token, address leaf, uint256 amount) private
    returns (
      address node,
      uint256 transferred
    )
  {
    node = umbrellaList[leaf].owner;

    if (node == address(0)) {
      return (address(0), 0);
    }

    uint256 prc = umbrellaList[leaf].percent;
    transferred = amount.mul(prc).div(divider);

    if (transferred == 0) {
      return (address(0), 0);
    }

    if (ERC20(_token).balanceOf(this) < transferred) {
      return (address(0), 0);
    }

    if (!ERC20(_token).transfer(node, transferred)) {
      return (address(0), 0);
    }

    return (node, transferred);
  }

  function loopUmbrella(address _token, address affil, uint256 amount) external onlyOwner
    returns(
      bool
    )
  {
    address a = affil;
    uint256 am = amount;

    while (a != address(0)) {
      (a, am) = doTransfer(_token, a, am);
    }

    return true;
  }

  event UmbrellaAdded(
    address indexed _umb,
    address indexed _holder,
    uint256 _percent
  );
}