// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 房源管理合约：
    1，个人房源信息上传
    2，个人房源信息修改
*/

contract propertyManagement{

    //新增房屋事件
    event PropertyAdded(
        uint256 propertyId,
        bool isAvailable,
        uint256 monthlyRent,
        string propertyType,
        string description,
        string photos,
        string location,
        address owner
    );
 
    //房屋属性
    struct Property{
        uint256 propertyId;       //房屋id
        bool isAvailable;         //房屋是否可租
        bool isWithdraw;          //房屋是否下架
        uint256 monthlyRent;      //月租金
        string propertyType;      //房屋类型，如“两室一厅”
        string description;       //房屋描述
        string photos;            //房屋图片
        string location;          //房屋地址
        address owner;            //房屋拥有者
    }

    mapping(uint256 => Property)public properties;//房源信息存储
    uint256 public propertyCount;// 房屋总数量

    //限制房屋信息修改者只有房屋拥有者
    modifier onlyOwner(
        uint256 _propertyId
        ){
        // require(properties[_propertyId].owner == tx.origin,"Property:you aren't the owner of the property");
        _;
    }

    //新增房屋
    function addProperty(
        bool _isAvailable, 
        uint256 _monthlyRent, 
        string memory _propertyType, 
        string memory _description,
        string memory _photos,
        string memory _location
    ) external returns(bool){
        propertyCount++; // 自增房屋ID

        properties[propertyCount] = Property(propertyCount, _isAvailable,false, _monthlyRent, _propertyType, _description, _photos, _location,tx.origin);

        emit PropertyAdded(propertyCount, _isAvailable, _monthlyRent, _propertyType, _description, _photos, _location,tx.origin);
        return true;
    }

    // 获取房屋全部信息
    function getProperty(
        uint256 _propertyId
    ) external view returns (Property memory){
        return properties[_propertyId];
    }

    // 获取房产房东
    function getPropertyOwner(
        uint _propertyId
    ) external view returns(address){
        return properties[_propertyId].owner;
    }

    // 更新代租状态
    function updateAvailability(
        uint256 _propertyId,
        bool _isAvailable
    ) external onlyOwner(_propertyId) returns(bool){
        properties[_propertyId].isAvailable = _isAvailable;

        return true;
    }

    // 更新下架状态
    function updateWithdrawal(
        uint256 _propertyId,
        bool _isWithdraw
    )external onlyOwner(_propertyId)returns(bool){
        if(properties[_propertyId].isWithdraw != _isWithdraw){
            properties[_propertyId].isWithdraw = _isWithdraw;
        }
        return true;
    }

    // 更新月租金
    function updateMonthlyRent(
        uint256 _propertyId,
        uint256 _monthlyRent
    )external onlyOwner(_propertyId) returns(bool){
        if(properties[_propertyId].monthlyRent != _monthlyRent){
            properties[_propertyId].monthlyRent = _monthlyRent;
        }

        return true;
    }

    // 更新房屋描述
    function updateMonthlyDescription(
        uint256 _propertyId,
        string memory _description
    )external onlyOwner(_propertyId) returns(bool){
        properties[_propertyId].description = _description;

        return true;
    }
}