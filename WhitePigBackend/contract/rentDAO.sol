// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./userInformation.sol";
import "./propertyRentERC20.sol";

interface IRentDeal{

    //租房交易
    struct Deal {
        address roomer;       // 房客
        address landord;      // 房东
        uint propertyId;      // 房产编号
        uint rentTimeStart;   // 起租时间
        uint rentTimeEnd;     // 结租时间
        bool isCompleted;     // 是否完成
        bool isDisputed;      // 是否纠纷
        string rentContract;  // 租房合同
    }

    //纠纷
    struct Dispute {
        uint disputeId;             //纠纷id
        uint dealId;                //交易id
        uint256 deadline;           // 投票截止时间
        string disputeDescription;  //纠纷描述
        string proof;               //纠纷证据
        uint256 votesFor;           // 支持票数
        uint256 votesAgainst;       // 反对票数
        bool executed;              //是否执行
        address roe;                //被告人地址
    }

    //提案
    struct Proposal {
        string description;   // 提案描述
        uint256 votesFor;     // 支持票数
        uint256 votesAgainst; // 反对票数
        uint256 deadline;     // 投票截止时间
        bool executed;        // 是否已执行
        address proposer;     // 提案人地址
    }

    //评价
    struct Remark {
        uint grade;
        string wards;
        bool isRemark;
    }
}

contract rentDAO is IUserInformation,IRentDeal{

    userInformation internal user;
    propertyRentERC20 internal rrt;

    mapping(address => bool) private members;        // DAO成员列表
    mapping(uint256 => Proposal) private proposals;  // 提案列表
    mapping(uint => Deal)public deals;              // 交易列表
    mapping(uint => Dispute)public disputes;        // 纠纷列表
    mapping(uint dealId=> mapping(address => Remark)) private remarks;   // 评价列表
    mapping(uint => bool) public isPawned;          // 是否提交押金

    uint256 public proposalCount;                   // 提案计数
    uint public disputeCount;                       // 纠纷计数

    event MemberRegistered(address member);
    event ProposalCreated(uint256 proposalId, string description, address proposer);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 proposalId, bool success);

    constructor(address _user,address _RRT){
        user = userInformation(_user);
        rrt = propertyRentERC20(_RRT);
    }

    modifier onlyMember() {
        require(members[tx.origin], "DAO:Only DAO members can perform this action");
        _;
    }

    // 查看租房完成状态
    function checkIsCompleted(
        uint _propertyId
    ) public returns(bool){
        uint end = deals[_propertyId].rentTimeStart;

        if(block.timestamp >= end){
            deals[_propertyId].isCompleted = true;
            return true;
        }

        return false;
    }

    // DAO成员纠纷投票(1)投了还可以投
    function voteOnDispute(
        uint disputeId,
        bool support
    ) external onlyMember {
        require(block.timestamp <= disputes[disputeId].deadline, "DAO:Voting period has ended");
        require(!disputes[disputeId].executed, "DAO:Dispute already executed");

        if (support) {
            disputes[disputeId].votesFor++;
        } else {
            disputes[disputeId].votesAgainst++;
        }

        rrt.mint(1e18);

        emit Voted(disputeId, msg.sender, support);
    }

    // DAO成员处理纠纷
    function resolveDispute(
        uint disputeId
    ) external onlyMember {
        Dispute storage dispute = disputes[disputeId];
        require(block.timestamp > dispute.deadline, "DAO:Voting period is not over");
        require(!dispute.executed, "DAO:Dispute already executed");

        if (disputes[disputeId].votesFor > disputes[disputeId].votesAgainst) {
            //扣除被告方的信誉积分
            uint _start = deals[disputes[disputeId].dealId].rentTimeStart;
            uint _end = deals[disputes[disputeId].dealId].rentTimeEnd;
            uint _count = (_end - _start) / 1 minutes;
            uint adjustment = _count*30 /360;
            user.deputeUserReputation(disputes[disputeId].roe,adjustment);
        }

        dispute.executed = true;

        rrt.mint(2e18);

        emit ProposalExecuted(disputeId, true);
    }

    // DAO成员注册函数
    function registerAsMember() external {
        require(!members[tx.origin], "DAO:Already a member");
        require(user.getUserReputation(tx.origin) >= 90,"DAO:reputation not enougth");

        members[tx.origin] = true;
        rrt.mint(1e18);

        emit MemberRegistered(msg.sender);
    }

    // 创建提案(DAO内部提案)
    function createProposal(
        string memory description
    ) external onlyMember returns (bool){
        proposals[proposalCount] = Proposal({
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            deadline: block.timestamp + 3 minutes, // 投票时间为3天(便于测试用1min代表一天)
            executed: false,
            proposer: tx.origin
        });
        proposalCount++;

        emit ProposalCreated(proposalCount, description, tx.origin);
        return true;
    }

    // 投票 
    function vote(
        uint256 proposalId,
        bool support
    ) external onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "DAO:Voting period has ended");

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        rrt.mint(1e18);

        emit Voted(proposalId, msg.sender, support);
    }

    // 执行提案 
    function executeProposal(
        uint256 proposalId
    ) external onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "DAO:Voting period is still active");
        require(!proposal.executed, "DAO:Proposal already executed");

        bool success = proposal.votesFor > proposal.votesAgainst;
        proposal.executed = true;

        if (success) {
            // 在此处实现提案通过后的具体逻辑，例如分配信誉积分、处理租房纠纷等
        }
        rrt.mint(2e18);

        emit ProposalExecuted(proposalId, success);
    }

    // 是否为DAO成员
    function isMember() public view returns(bool){
        return members[tx.origin];
    }

    // 查看纠纷结果（内部）
    function _getDisputeResult(
        uint _propertyId
    ) external view returns(Dispute memory){
        return disputes[_propertyId];
    }

    // 添加一笔租房交易（内部）
    function addDeal(
        address _roomer,
        address _landord,
        uint _propertyId,
        uint _rentTimeStart,
        uint _rentTimeEnd,
        bool _isCompleted,
        bool _isDisputed,
        string memory _rentContract
    )external returns(bool){
        require(_roomer != address(0) && _landord != address(0),"");

        deals[_propertyId] = Deal({
            roomer: _roomer,
            landord: _landord,
            propertyId: _propertyId,
            rentTimeStart: _rentTimeStart,
            rentTimeEnd: _rentTimeEnd,
            isCompleted: _isCompleted,
            isDisputed: _isDisputed,
            rentContract: _rentContract
        });

        return true;
    }

    // 修改是否提交押金(内部)
    function setIsPawned(
        uint _propertyId,
        bool _isPawned
    ) external {
        isPawned[_propertyId] = _isPawned;
    }

    // 评价功能
    function rateDeal(
        uint dealId,
        uint _grade,
        string memory _wards
    ) external {
        Deal storage deal = deals[dealId];
        require(deal.isCompleted, "DAO:Deal is not completed");
        require(tx.origin == deal.roomer || tx.origin == deal.landord,"DAO:Not authorized to rate");
        require(!remarks[dealId][tx.origin].isRemark, "DAO:Already rated");

        address otherParty = (tx.origin == deal.roomer)
            ? deal.landord
            : deal.roomer;                                    // 获取对方地址
        remarks[dealId][tx.origin].isRemark = true;           // 标记当前用户已评价

        remarks[dealId][otherParty].wards = _wards;           // 对方在这笔交易中获得的评价
        remarks[dealId][otherParty].grade = _grade;

        uint currentReputation = user.getUserReputation(otherParty);//当前信誉积分
        uint _start = deals[dealId].rentTimeStart;
        uint _end = deals[dealId].rentTimeEnd;

        if(_grade >= 90){
            user.addUserReputation(otherParty,currentReputation,2*(_end - _start)/ 1 minutes);
        }else if(_grade >= 60){
            user.addUserReputation(otherParty,currentReputation,(_end - _start)/1 minutes);
        }else{
            user.addUserReputation(otherParty,currentReputation,(_end - (2*_start))/1 minutes);
        }
    }

    // 用户提交纠纷
    function submitDispute(
        uint dealId,
        string memory description,
        string memory proof,
        address roe
    ) external {
        require(!deals[dealId].isDisputed, "DAO:Deal already disputed");
        require(deals[dealId].roomer == tx.origin || deals[dealId].landord == tx.origin, "DAO:Not authorized");

        disputeCount++;
        disputes[disputeCount] = Dispute({
            disputeId: disputeCount,
            dealId: dealId,
            deadline: block.timestamp + 5 minutes, // 5天，这里用1min代替一天。
            disputeDescription: description,
            proof: proof,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            roe: roe
        });

        deals[dealId].isDisputed = true;
    }
}