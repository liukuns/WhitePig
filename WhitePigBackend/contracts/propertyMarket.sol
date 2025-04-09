// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./propertyRentERC20.sol";
import "./userInformation.sol";
import "./rentDAO.sol";
import "./propertyManagement.sol";
import "./usdt.sol";
import "./rentRequest.sol";

/* 租房合约：
    1，租客可以租房
*/

 contract propertyMarket is IRentDeal{
 
    propertyManagement private pm;
    userInformation private user;
    usdt private USDT;
    rentDAO private dao;
    rentRequest private request;
    // 房屋属性
    struct Property{
        uint256 propertyId;    //房屋id
        bool isAvailable;      //房屋是否可租
        bool isWithdraw;       //房屋是否下架
        uint256 monthlyRent;   //月租金
        string propertyType;   //房屋类型，如“两室一厅”
        string description;    //房屋描述
        string photos;         //房屋图片
        string location;       //房屋地址
        address owner;         //房屋拥有者
    }

    mapping(address => Property[]) private propertiesByOwner; //用户拥有的房源

    constructor(address _pm,address _usdt,address _user,address _dao){
        pm = propertyManagement(_pm);
        user = userInformation(_user);
        USDT = usdt(_usdt);
        dao = rentDAO(_dao);
        //request = rentRequest(_request);
    }

    // 上传房源
    function addPropertyMarket(
        uint256 _monthlyRent, 
        string memory _propertyType, 
        string memory _description,
        string memory _photos,
        string memory _location
    ) external returns(bool){
        require(
            !user._isBlacklisted(tx.origin) && user.isAddressBound(tx.origin),
            "Market:Identify failed!"
        );
        require(
            pm.addProperty(true,_monthlyRent,_propertyType,_description,_photos,_location),
            "Market:add property failed!"
        );
        propertiesByOwner[tx.origin].push(Property(
            pm.propertyCount(), 
            true,
            false, 
            _monthlyRent,
            _propertyType,
            _description, 
            _photos,
            _location,
            tx.origin
        ));
        return true;
    }

    // 拿到该用户的房源(用户)
    function getMyProperty()public view returns(Property[] memory){
        return propertiesByOwner[tx.origin];
    }

    // 拿到全部用户的房源数量(页面)
    function getAllProperty()public view returns(uint){
        return pm.propertyCount();
    }

    // 租房(需要用户先转USDT给合约)
    function rent(
        uint _propertyId,
        uint _monthCount,
        string memory _rentContract
    ) external returns(bool){  
        // 验证是否获得了租房许可  
        // 验证身份是否合法
        require(
            !user._isBlacklisted(tx.origin) && user.isAddressBound(tx.origin),
            "Market:Identify failed!"
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
            block.timestamp + _monthCount * 1 minutes, //这里用1min来代替一天
            false,
            false, 
            _rentContract
        );

        return true;
    }

    // 查看租房状态
    function checkIsCompleted(
        uint _propertyId
    )external returns(bool){
        return dao._checkIsCompleted(_propertyId);
    }

    // 用户发起评价
    function remark(
        uint _propertyId,
        uint _grade,
        string memory _wards
    ) external returns(bool){
        require(_grade * _propertyId != 0,"Market: invaild input number!");

        pm.updateAvailability(_propertyId,true);
        pm.updateWithdrawal(_propertyId,false);
        dao.rateDeal(_propertyId,_grade,_wards);

        return true;
    }

    // 查看评价结果（内部）
    function getRemark(
        uint _propertyId,
        address _owner
    )external view returns(Remark memory){
        return dao._getRemark(_propertyId,_owner);
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
        uint _dealId
    ) external view returns(Dispute memory){
        return dao._getDisputeResult(_dealId);
    }

    // 房东退还押金（需要用户先转USDT给合约）
    function chargeback(
        uint _propertyId
    ) external returns(bool){
        (address roomer,address landord, ,uint256 rentTimeStart, uint256 rentTimeEnd, , ,) = dao.deals(_propertyId);
        // 检查地址是否为房东
        require(tx.origin == landord,"Market:Only landord can do it!");
        // 检查是否需要退还
        require(dao.isPawned(_propertyId),"Market:don't need to chargeback");

        // 进行押金退还（押金10%，转账金额）
        uint _monthCount = (rentTimeEnd - rentTimeStart) / 1 minutes;
        uint _rentAmount = _monthCount * pm.getProperty(_propertyId).monthlyRent;
        uint _deposite = ( _rentAmount * 10 ) / 100;

        require(USDT.balanceOf(tx.origin) >= _deposite,"Market:balance not enough!");
        USDT.transfer(roomer, _deposite);
        dao.setIsPawned(_propertyId,false);

        return true;
    }


 }