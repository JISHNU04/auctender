// We will be using Solidity version 0.5.3
pragma solidity ^0.4.8;
// Importing OpenZeppelin's SafeMath Implementation


contract Auction {
    
    
    address public owner; 
    string title;
    uint startPrice;
    string description;

    enum State{Default, Running, Finalized}
    State public auctionState;

    uint public highestPrice;
    address public highestBidder;
    mapping(address => uint) public bids;
    
    
    constructor() public{
        owner=msg.sender;
    }
     function x(string memory _title,
        uint _startPrice,
        string memory _description) public{
        title = _title;
        startPrice = _startPrice;
        description = _description;
        auctionState = State.Running;
     }
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }
    
   
    
    function placeBid(uint x) public payable notOwner returns(bool) {
        require(auctionState == State.Running);
        require(x > 0);
        // update the current bid
        // uint currentBid = bids[msg.sender] + msg.value;
        bids[msg.sender]=x;
        uint currentBid =bids[msg.sender]; 
        require(currentBid > highestPrice);
        // set the currentBid links with msg.sender
        bids[msg.sender] = currentBid;
        // update the highest price
        highestPrice = currentBid;
        highestBidder = msg.sender;
        
        return true;
    }
    
    function finalizeAuction() public{
        //the owner and bidders can finalize the auction.
        require(msg.sender == owner || bids[msg.sender] > 0);
        
        address recipiant;
        uint value;
        
        // owner can get highestPrice
        if(msg.sender == owner){
            recipiant = owner;
            value = highestPrice;
        }
        // highestBidder can get no money
        else if (msg.sender == highestBidder){
            recipiant = highestBidder;
            value = 0;
        }
        // Other bidders can get back the money 
        else {
            recipiant = msg.sender;
            value = bids[msg.sender];
        }
        // initialize the value
        bids[msg.sender] = 0;
        recipiant.transfer(value);
        auctionState = State.Finalized;
    }
   
    
    function returnContents() public view returns(        
        string memory,
        uint,
        string memory,
        State
        ) {
        return (
            title,
            startPrice,
            description,
            auctionState
        );
    }
    
}