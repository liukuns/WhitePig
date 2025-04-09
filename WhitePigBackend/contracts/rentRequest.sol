// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./propertyManagement.sol";
import "./userInformation.sol";

interface IrentRequest {

    // 联系请求结构体
    struct ConRequest {
        uint conRequestId;       // 联系请求id
        address sender;          // 发送方
        address lord;            // 接收方
        uint propertyId;         // 房源编号
        string content;          // 发送内容
        bool approved;           // 是否同意
    }

    // 租房请求
    struct RentRequest {
        uint rentRequestId;  // 租房请求id
        address sender;          // 发送方
        address lord;            // 接收方
        uint propertyId;         // 房源编号
        string content;          // 是否同意
        bool approved;           // 是否同意
    }
}

contract rentRequest is IrentRequest{
    propertyManagement pm;
    userInformation uInfo;

    mapping(uint => ConRequest) private conRequests;            // 联系请求列表
    mapping(uint => RentRequest) private rentRequests;          // 租房请求列表

    mapping(address => uint[]) private sendConRequests;         // 房客 发起的联系请求列表
    mapping(address => uint[]) private sendRentRequests;        // 房客 发起的租房请求列表

    mapping(address => uint[]) private receivedConRequests;     // 房东 收到的联系请求列表
    mapping(address => uint[]) private receivedRentRequests;    // 房东 收到的租房请求列表

    uint public conRequestCount;// 联系请求计数器
    uint public rentRequestCount;// 租房请求计数器

    constructor(address _pm,address _uInfo){
        pm = propertyManagement(_pm);
        uInfo = userInformation(_uInfo);
    }
 
    // 根据联系请求id查看请求
    function getConRequestById(
        uint _conRequestId
    ) external view returns(ConRequest memory){
        require(conRequests[_conRequestId].propertyId != 0,"Request:conRequest hasn't exit!");

        return conRequests[_conRequestId];
    }

    // 根据租房请求id查看请求
    function getRentRequestById(
        uint _rentRequestId
    ) external view returns(RentRequest memory){
        require(rentRequests[_rentRequestId].propertyId != 0,"rentRequest:rentRequest hasn't exit!");

        return rentRequests[_rentRequestId];
    }

    // 查看联系请求列表
    function getConRequests(
        bool _isRoomer
    ) external view returns (uint[] memory){
        if(_isRoomer){
            return sendConRequests[tx.origin];
        }
        return receivedConRequests[tx.origin];
    }

    // 查看租房请求列表
    function getRentRequests(
        bool _isRoomer
    ) external view returns (uint[] memory){
        if(_isRoomer){
            return sendRentRequests[tx.origin];
        }
        return receivedRentRequests[tx.origin];
    }

    // 房客发起联系请求
    function sendConRequest(
        uint _propertyId,
        string memory _content
    )external returns(bool){
        address owner = pm.getPropertyOwner(_propertyId);
        require(uInfo.isAddressBound(tx.origin),"Request:the user hasn't bound");
        require(owner != address(0),"Request:Invalid property ID!");

        conRequestCount++;
        conRequests[conRequestCount] = ConRequest({
            conRequestId: conRequestCount,
            sender: tx.origin,
            lord: owner,
            propertyId:_propertyId,
            content: _content,
            approved: false
        });
        sendConRequests[tx.origin].push(conRequestCount);
        receivedConRequests[owner].push(conRequestCount);

        return true;
    }

    // 房东处理联系请求
    function handleConRequest(
        uint _conRequestId,
        bool _isApproved
    ) external returns(bool){
        address _sender = conRequests[_conRequestId].sender;
        require(_sender != address(0),"Request:Wrong conRequest message ID!");

        conRequests[_conRequestId].approved = _isApproved;

        return _isApproved;
    }

    // 房客发起租房请求
    function sendRentRequest(
        uint _propertyId,
        string memory _content
    )external returns(bool){
        address owner = pm.getPropertyOwner(_propertyId);
        require(uInfo.isAddressBound(tx.origin),"Request:the user hasn't bound");
        require(owner != address(0),"Request:Invalid property ID!");

        rentRequestCount++;
        rentRequests[rentRequestCount] = RentRequest({
            rentRequestId: rentRequestCount,
            sender: tx.origin,
            lord: owner,
            propertyId:_propertyId,
            content: _content,
            approved: false
        });
        sendRentRequests[tx.origin].push(rentRequestCount);
        receivedRentRequests[owner].push(rentRequestCount);

        return true;
    }  

    // 房东处理租房请求
    function handleRentRequest(
        uint _rentRequestId,
        bool _isApproved
    ) external returns(bool){
        address _roomer = rentRequests[_rentRequestId].sender;
        require(_roomer != address(0),"Request:Wrong conRequest message ID!");

        conRequests[_rentRequestId].approved = _isApproved;

        return _isApproved;
    }
}