// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//治理token Rent Reputation Token(RRT)
contract propertyRentERC20 is ERC20{
    
    constructor(string memory name_,string memory symbol)ERC20(name_,symbol){}

    function mint(uint amount)external {
        _mint(tx.origin, amount);
    }
}