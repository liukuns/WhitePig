// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./propertyRentERC20.sol";
import "./userInformation.sol";
import "./rentDAO.sol";
import "./propertyManagement.sol";
import "./usdt.sol";

/* 租房合约：
    1，租客可以租房
*/

 contract propertyRent is IRentDeal{
    
    propertyManagement public pm;
    userInformation public user;
    usdt public USDT;
    rentDAO public dao;

    // 房屋属性
    struct Property{
        uint256 propertyId;    //房屋id
        bool isAvailable;      //房屋是否可租
        bool isWithdraw;       //房屋是否下架
        uint256 monthlyRent;   //月租金
        string propertyType;   //房屋类型，如“两室一厅”
        string description;    //房屋描述
        string location;       //房屋地址
        address owner;         //房屋拥有者
    }

    mapping(address => Property[]) public propertiesByOwner; //用户拥有的房源

    constructor(address _pm,address _usdt,address _user){
        pm = propertyManagement(_pm);
        user = userInformation(_user);
        USDT = usdt(_usdt);
    }

    // 上传房源
    function addPropertyMarket(
        bool _isAvailable, 
        uint256 _monthlyRent, 
        string memory _propertyType, 
        string memory _description,
        string memory _location
    ) external returns(bool){
        require(
            user._isBlacklisted(tx.origin) && user.isAddressBound(tx.origin),
            "Identify failed!"
        );
        require(
            pm.addProperty(true,_monthlyRent,_propertyType,_description,_location),
            "add property failed!"
        );
        propertiesByOwner[tx.origin].push(Property(
            pm.propertyCount(), 
            _isAvailable,false, 
            _monthlyRent,
            _propertyType,
            _description, 
            _location,tx.origin
        ));

        //考虑是否用提高上传房源的成本（防止非法房源）

        return true;
    }

    // 拿到该用户的房源
    function getProperty()public view returns(Property[] memory){
        return propertiesByOwner[tx.origin];
    }

    // 拿到全部用户的房源数量
    function getAllProperty()public view returns(uint){
        return pm.propertyCount();
    }

    // 租房
    function rent(
        uint _propertyId,
        uint _monthCount,
        string memory _rentContract
    ) external returns(bool){    
        // 验证身份是否合法
        require(
            user._isBlacklisted(tx.origin) && user.isAddressBound(tx.origin),
            "Identify failed!"
        );
        // 房屋是否可租
        require(pm.getProperty(_propertyId).isAvailable,"Market:the room can't be rented now!");
        
        // 进行租金转账（押金10%，转账金额）
        uint _rentAmount = _monthCount * pm.getProperty(_propertyId).monthlyRent;
        uint _deposite = ( _rentAmount * 10 ) / 100;

        if(user.getUserReputation(tx.origin) > 80){
            require(USDT.balanceOf(tx.origin) >= _rentAmount,"Market:balance not enough!");
            USDT.transfer(pm.getPropertyOwner(_propertyId), _rentAmount);
        }else{
            require(USDT.balanceOf(tx.origin) >= _rentAmount + _deposite,"Market:balance not enough!");
            // 如果交易结束，用户为归还押金，房客则可以进行投诉
            USDT.transfer(pm.getPropertyOwner(_propertyId), _rentAmount + _deposite);
            dao.setIsPawned(_propertyId,true);
        }
        pm.updateAvailability(_propertyId,false);
        pm.updateWithdrawal(_propertyId,false);

        // 添加租房交易
        dao.addDeal(
            tx.origin,
            pm.getPropertyOwner(_propertyId), 
            _propertyId, 
            block.timestamp,
            block.timestamp + _monthCount * 31, 
            false, 
            false, 
            _rentContract
        );

        return true;
    }

    // 房东退还押金
    function chargeback(
        uint _propertyId
    ) external returns(bool){
        //检查是否需要退还
        require(dao.isPawned(_propertyId),"Market:don't need to chargeback");

        // 进行押金退还（押金10%，转账金额）
        (, , uint256 rentTimeStart, uint256 rentTimeEnd, , , ,) = dao.deals(_propertyId);
        uint _monthCount = (rentTimeEnd - rentTimeStart) / 31;
        uint _rentAmount = _monthCount * pm.getProperty(_propertyId).monthlyRent;
        uint _deposite = ( _rentAmount * 10 ) / 100;

        require(USDT.balanceOf(tx.origin) >= _rentAmount,"Market:balance not enough!");
        USDT.transfer(pm.getProperty(_propertyId).owner, _deposite);
        dao.setIsPawned(_propertyId,false);

        return true;
    }

    // 用户发起评价
    function remark(
        uint _propertyId,
        uint _grade
    ) external returns(bool){
        require(_grade * _propertyId != 0,"Market: invaild input number!");

        pm.updateAvailability(_propertyId,true);
        pm.updateWithdrawal(_propertyId,true);
        dao.rateDeal(_propertyId,_grade);

        return true;
    }

    //发起投诉
    function complain(
        uint _propertyId,
        string memory _description,
        string memory _proof
    ) external returns(bool){

        dao.submitDispute(
            _propertyId,
            _description,
            _proof,
            pm.getPropertyOwner(_propertyId)
        );

        return true;
    }

    //查看投诉结果
    function getDisputeResult(
        uint _propertyId
    ) external view returns(Dispute memory){
        return dao._getDisputeResult(_propertyId);
    }
 }