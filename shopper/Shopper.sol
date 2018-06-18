pragma solidity ^0.4.18;

import './Ownable.sol';
import './SafeMath.sol';

contract Shopper is Ownable {
    using SafeMath for uint;

    mapping (address => uint) buys;
    mapping (address => bytes) items;
    uint private _reserved = 0;

    modifier sameItem(bytes item_in, uint price) {
        require(
            buys[msg.sender] == price &&
            keccak256(items[msg.sender]) == keccak256(item_in)
        );
        _;
    }

    function () payable public {
        require(buys[msg.sender] == 0);
        buys[msg.sender] = msg.value;
        items[msg.sender] = msg.data;
        _reserved = _reserved.add(msg.value);
        OnBuy(msg.sender, msg.value, msg.data);
    }

    function item() view public returns (bytes s) {
        s = items[msg.sender];
    }

    function bl() view public returns (uint s) {
        s = buys[msg.sender];
    }

    function clear(uint _value) private {
        buys[msg.sender] = 0;
        items[msg.sender] = '';
        _reserved = _reserved.sub(_value);
    }

    function confirm(bytes item_in, uint price) public sameItem(item_in, price) {
        clear(price);
        OnConfirm(msg.sender, price, item_in);
    }

    function unconfirm(bytes item_in, uint price) public sameItem(item_in, price)  {
        msg.sender.transfer(buys[msg.sender]);
        clear(price);
        OnCancel(msg.sender, price, item_in);
    }

    function isOwner() view public returns (bool b) {
        b = msg.sender == owner;
    }

    function sumWithdraw() view public returns (uint) {
        return this.balance.sub(_reserved);
    }

    function withdraw() public onlyOwner {
        require(this.balance > _reserved);
        uint wisum = this.balance.sub(_reserved);
        owner.transfer(wisum);
        OnWithdraw();
    }

    function reserved() view public onlyOwner returns (uint) {
        return _reserved;
    }

    event OnBuy(address indexed buyer, uint price, bytes item_in);
    event OnConfirm(address indexed buyer, uint price, bytes item_in);
    event OnCancel(address indexed buyer, uint price, bytes item_in);
    event OnWithdraw();
}
