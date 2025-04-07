// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//USDT 交易代币
contract usdt is ERC20{

    constructor(string memory name_,string memory symbol)ERC20(name_,symbol){
    }

    function mint(uint amount)external {
        _mint(tx.origin, amount);
    }

    // 计算租房费用（租房交易完成使用）
    function getRentAmount(
        uint rentTimeStart,
        uint256 rentTimeEnd
    )public pure returns(uint){
        uint _monthCount = (rentTimeEnd - rentTimeStart) / 1 minutes;
        uint _rentAmount = _monthCount * 1500;

        return _rentAmount;
    }
    //1743667141  1743667261

    // 计算租房押金（租房交易使用）
    function getDeposite(
        uint _rentAmount
    )public pure returns(uint){
        return ( _rentAmount * 10 ) / 100;
    }
}