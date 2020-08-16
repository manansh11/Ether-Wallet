pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

contract Wallet {
    address[] public approvers;
    uint public quorum;
    
    
    struct Transfer {
        uint id;
        uint amount;
        //**payable -> allows us to send ether to this address
        address payable to;
        uint approvals;
        bool sent;
    }
    
    

    Transfer[] public transfers;
    mapping(address => mapping(uint => bool)) public approvals;
    
    
    //Function constructor
    constructor(address[] memory _approvers, uint _quorum) public{
        approvers = _approvers;
        quorum = _quorum;
    }
    
    
    
    /** Function Declaration: getApprovers()
        **external -> means that this function is available outside the smart contract
        ** view -> means that this function is read only
    **/
    function getApprovers() external view returns(address[] memory){
        return approvers;
    }
    
    function getTransfers() external view returns(Transfer[] memory){
        return transfers;
    }
    
    
    
    /** Function Declaration: createTransfer()
        **Access the mapping called ( transfers ) using nextId as the index and  
    **/
    
    function createTransfer(uint amount, address payable to) external onlyApprover {
        transfers.push(Transfer(
            transfers.length,
            amount,
            to,
            0,
            false
            ));
    }
    
    
    /** function Declaration: approveTransfer()
        ** requires that the transfer has NOT already been sent and that it has NOT been already approved
        ** IF passes that requirement, then set approvals[msg.sender][id] = true; and add a approvals
        ** 
        **
    
    **/
    
    function approveTransfer(uint id) external onlyApprover {
        require(transfers[id].sent == false, 'transfer has already been sent');
        require(approvals[msg.sender][id] == false, 'cannot approve transfer twice');
        
        approvals[msg.sender][id] = true;
        transfers[id].approvals++;
        
        if(transfers[id].approvals >= quorum){
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            to.transfer(amount);
        }
        
    }
    
    //Allow ether to be recieved
    
    receive() external payable {} 
    
    
    
    //function modifier
    
    modifier onlyApprover() {
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++){
            if(approvers[i] == msg.sender){
                allowed = true;
            }
        }
        require(allowed == true, 'only approver allowed');
        _;
    }
    
    }
