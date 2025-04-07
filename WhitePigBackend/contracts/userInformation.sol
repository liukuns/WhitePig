// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// 定义接口
interface IUserInformation {
    // 用户身份信息结构体
    struct UserInfo {
        string idHash;        // 用户的数字身份证（哈希后的值）
        address wallet;       // 用户的钱包地址
        uint256 reputation;   // 用户信誉积分
        string number;        // 用户的手机号
        bool isBound;         // 数字身份证是否绑定
    }
}

contract userInformation is IUserInformation{

    mapping(string => bool) private isBlacklisted;  // 数字身份证黑名单
    mapping(address => UserInfo) private userInfos; // 用户地址对应的身份信息
    mapping(string => bool) private isBoundId;      // 判断数字身份证是否绑定过

    uint256 constant INITIAL_REPUTATION = 60;     // 初始信誉积分
    uint256 constant MAX_REPUTATION = 100;        // 信誉积分上限
    uint constant private ANNUAL_INCREASE = 930;  // 信誉积分增长因子

    // 身份认证和绑定
    function verify(
        string memory _id,
        string memory _number
    ) external returns (bool) {
        // 对用户输入的身份证号进行哈希计算
        string memory idHash = hashId(_id);

        // 检查数字身份证是否为黑名单用户
        require(!isBlacklisted[idHash], "User:ID is blacklisted");

        // 检查用户是否已绑定过数字身份证
        require(!userInfos[tx.origin].isBound, "User:Address already bound");
        require(!isBoundId[idHash], "User:ID already bound");

        // 完善用户身份信息
        userInfos[msg.sender] = UserInfo({
            idHash: idHash,
            wallet: tx.origin,
            reputation: INITIAL_REPUTATION,
            number: _number,
            isBound: true
        });
        isBoundId[idHash] = true;

        return true;
    }

    // 查询用户的身份信息
    function getUserInfo(
        address _add
    )external view returns(UserInfo memory){
        require(isAddressBound(_add),"User:the address havn't bound");

        return userInfos[_add];
    }

    // 修改数字身份证绑定的地址

    // 添加用户黑名单
    function _addBlacklisted(
        address _add
    )external{
        if(isAddressBound(_add)){
            string memory _id = userInfos[_add].idHash;
            isBlacklisted[_id] = true;
        }
    }

    // 增加用户信誉积分
    function addUserReputation(
        address _user,
        uint _currentScore,
        uint _dayRent
    )external returns(bool){
        uint _adjustment = calculateReputationIncrease(_currentScore,_dayRent);
        userInfos[_user].reputation =_adjustment;

        return true;
    }

    // 扣除用户信誉积分
    function deputeUserReputation(
        address _user,
        uint _adjustment
    )external returns(bool){
        userInfos[_user].reputation -=_adjustment;
        return true;
    }
    
    // 查看用户是否为黑名单用户(前提是进行过身份绑定)
    function _isBlacklisted(
        address _add
    ) external view returns(bool){
        return isBlacklisted[userInfos[_add].idHash];
    }

    //查询用户的信誉积分
    function getUserReputation(
        address _add
    ) external view returns(uint){
        require(isAddressBound(_add),"User:the address havn't bound");

        return  userInfos[_add].reputation;
    }

    // 查询用户地址是否绑定过
    function isAddressBound(
        address _add
    ) public view returns (bool) {
        require(_add != address(0),"User:address can't be a zero address");

        bool isAddBound = userInfos[_add].isBound;

        return isAddBound;
    }
    
    // 查询用户的数字身份证是否绑定过
    function isIdBound(
        string memory _id
    ) internal view returns(bool) {
        string memory idHash = hashId(_id);
        bool _isIdBound = isBoundId[idHash];

        return _isIdBound;
    }

    // 用户完成一笔住房交易后信誉积分提高(修改为按月计算，同时1min代替1月)
    function calculateReputationIncrease(
        uint currentScore,
        uint daysRented
    ) public pure returns (uint) {
        uint dailyIncreaseBase = ANNUAL_INCREASE * 1e18 / 365; // 扩大精度以避免浮点运算
        uint factor = (MAX_REPUTATION - currentScore) * 1e18 / MAX_REPUTATION; // 当前积分影响提升速度
        uint dailyIncrease = dailyIncreaseBase * factor / 1e18;

        uint totalIncrease = dailyIncrease * daysRented / 1e18;
        uint newScore = currentScore + totalIncrease;

        // 确保不超过最大分数
        if (newScore > MAX_REPUTATION) {
            newScore = MAX_REPUTATION;
        }
        return newScore;
    }

    // 将用户的身份证hash为数字身份证
    function hashId(
        string memory _id
    ) internal pure returns (string memory) {
        // 对输入字符串进行哈希计算
        bytes32 hashed = keccak256(abi.encodePacked(_id));
        
        // 将哈希值转换为字符串
        return toHexString(hashed);
    }

    // 将bytes32 转换为十六进制字符串的辅助函数
    function toHexString(
        bytes32 data
    ) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i * 2] = alphabet[uint8(data[i] >> 4)];
            str[1 + i * 2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }

    // 白名单用户设置信誉积分
    function setReputationWhiteUser(
        uint _grade
    ) external returns(bool){
        require(isAddressBound(tx.origin),"User:Please bound with your identification!");

        userInfos[tx.origin].reputation = _grade;

        return true;
    }
}