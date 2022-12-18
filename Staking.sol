// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;



// This contract allows users to stake sToken in exchange for a chance to participate
// in an IDO (initial distribution event) for iToken. There are two types of staking:
// short term (15 days) and long term (90 days).

contract Staking {

    address public owner = msg.sender;
    // The minimum amount of sToken that can be staked to get a ticket.
    uint public constant FIXED_STAKE_AMOUNT = 0.00084 ether;
    
    
    // The amount of sToken staked by each user.
    mapping(address => uint) public stakes;
    // The number of tickets each user has.
    mapping(address => uint) public tickets;

    //This Mapping will tell how much amount is spent by an address
    mapping(address => uint) public amountPerAddress;

    // The timestamp at which short term staking begins.
    uint public shortTermStakingStart;

    // The timestamp at which short term staking ends.
    uint public shortTermStakingEnd;

    // The timestamp at which long term staking begins.
    uint public longTermStakingStart;

    // The timestamp at which long term staking ends.
    uint public longTermStakingEnd;

    // Event that is emitted when a user stakes sToken.
    event Staked(address indexed staker, uint amount);

    // Event that is emitted when a user unstakes sToken.
    event Unstaked(address indexed staker, uint amount);

    // Event that is emitted when a user's ticket count is updated.
    event TicketsUpdated(address indexed staker, uint ticketCount);

    // Stakes `amount` of sToken in exchange for a chance to participate in the IDO.
    // If the staking period has not yet begun, this function will throw an exception.

     modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can use this function");
        _;
    }


    function stakeShortTerm(uint amountOfTicket) public payable{
        // Check if the staking period has begun.
        require(block.timestamp>= shortTermStakingStart, "Staking period has not yet begun.");
        // Check if the staking period has ended.
        require(block.timestamp<= shortTermStakingEnd, "Staking period has ended.");
        // Check that the user has enough sToken to stake.
        require(msg.value == amountOfTicket*FIXED_STAKE_AMOUNT, "Insufficient balance.");
        // Calculate the number of tickets the user should receive.
        uint tokenCount = amountOfTicket*FIXED_STAKE_AMOUNT ;
        // Update the user's stake and ticket count.
        stakes[msg.sender] += tokenCount;
        tickets[msg.sender] += amountOfTicket;
        // Emit the Staked event.
        emit Staked(msg.sender, amountOfTicket);
        emit TicketsUpdated(msg.sender,amountOfTicket);
    }

    // long term function
    function stakeLongTerm(uint amountOfTicket) public payable{
    // Check if the long term staking period has begun.
    require(block.timestamp>= longTermStakingStart, "Long term staking period has not yet begun.");
    // Check if the long term staking period has ended.
    require(block.timestamp<= longTermStakingEnd, "Long term staking period has ended.");
    // Check that the user is staking the minimum amount.
    require(msg.value == amountOfTicket*FIXED_STAKE_AMOUNT , "Stake amount must be at least MIN_STAKE_AMOUNT.");
    // Check that the user has enough sToken to stake.
    require(msg.value >= amountOfTicket*FIXED_STAKE_AMOUNT, "Insufficient balance.");

    // Calculate the number of tickets the user should receive based on the boost factor for long term stakers.
    // amountPerAddress[msg.sender] = amountPerAddress[msg.sender] + msg.value; 
    uint ticketCount =  msg.value / FIXED_STAKE_AMOUNT * (12 % 1e1); //to do some confusion on floating

    /// Update the user's stake and ticket count.
    stakes[msg.sender] += ticketCount;
    tickets[msg.sender] += amountOfTicket;

    //After 90 days Period Unstake
    if(block.timestamp>=longTermStakingEnd) {
        stakes[msg.sender] -= ticketCount;
        tickets[msg.sender] -= amountOfTicket;
    }

    // Emit the Staked event.
    emit Staked(msg.sender, amountOfTicket);
    emit TicketsUpdated(msg.sender, ticketCount);
}

    function startShorttermStaking() public onlyOwner{

        shortTermStakingStart = block.timestamp;
        //1274980 --15 days
        shortTermStakingEnd = shortTermStakingStart + 1274980;
    
    }

    function startLongtermStaking() public onlyOwner {

        longTermStakingStart = block.timestamp;
        // 7771552 -- 90 days
        longTermStakingEnd   = longTermStakingStart + 7771552;
    }

    function unstakeShortTerm(uint amountOfToken) public {

    require(stakes[msg.sender]>0,"Insufficient token to unstake");
    require(block.timestamp>=shortTermStakingEnd,"Staking period is not over yet");
    stakes[msg.sender] -= amountOfToken*FIXED_STAKE_AMOUNT;
    tickets[msg.sender] -= amountOfToken;

    // Emit the Unstaked event.
    emit Unstaked(msg.sender, amountOfToken);


    }





}
    
