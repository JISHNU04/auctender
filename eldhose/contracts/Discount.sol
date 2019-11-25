pragma solidity ^0.5.0;

contract Discount {

    address payable private owner;
    string private projectDescription;
    uint public deposit;
    uint private biddingEnd;
    uint private revelationEnd;
    address public winner;
    uint private highestBid;
    bool private winnerExists;
    bool private checkedByOwner;
    mapping(address => closedBid) public hashedBids;
    mapping(address => bool) public bidExists;
    openBid[] public bidQueue;

    event tenderEndsWithWinner(address winner, uint bid);
    event tenderEndsWithoutWinner();

    struct closedBid {
        bytes32 hash;
        uint time;
    }

    struct openBid {
        uint amount;
        uint time;
        address payable owner;
    }

    // Bidding duration in minutes
    constructor() public {
        
         // Deposit in Ether
    }


    function generateHash(uint nonce, uint bidAmt) public pure returns (bytes32) {
        bytes memory toHash = abi.encodePacked(nonce, bidAmt);
        bytes32 hash = keccak256(toHash);
        return hash;
    }

    
    function makeTender(string memory desc, uint biddingDuration, uint revelationDuration, uint depositAmount) public{
        owner = msg.sender;
        projectDescription = desc;
        biddingEnd = now + (biddingDuration * 1 minutes);
        revelationEnd = biddingEnd + (revelationDuration * 1 minutes);
        deposit = depositAmount;
    }


    modifier onlyBefore(uint time) {
        require(now < time);
        _;
    }

    modifier onlyAfter(uint time) {
        require(now > time);
        _;
    }

    modifier ownerOnly() {
        require(owner == msg.sender);
        _;
    }

    function hasBidBefore(address bidder) public view returns (bool) {
        return bidExists[bidder];
    }

    function hasBeenChecked() public view onlyAfter(revelationEnd) returns (bool) {
      return checkedByOwner;
    }

    function isOwner(address user) public view returns (bool) {
      return (user == owner);
    }

    function hasWinner() public view onlyAfter(revelationEnd) returns (bool) {
      require(checkedByOwner);
      return winnerExists;
    }

    // Lets bidder submit hashed bids and ensures that bidders only make one bid each
    function makeBid(bytes32 hashedBid) public payable onlyBefore(biddingEnd) {
        if (hasBidBefore(msg.sender)) {
            hashedBids[msg.sender] = closedBid(hashedBid, now);
        } else {
           // require(msg.value == (deposit * 1 ether), "Deposit amount is incorrect!");
            hashedBids[msg.sender] = closedBid(hashedBid, now);
            bidExists[msg.sender] = true;
        }
    }

    // Checks revealed bid and adds to priority queue
    function revealBid(uint nonce, uint bidAmt) public  {
        require(hasBidBefore(msg.sender));

        bytes memory toHash = abi.encodePacked(nonce, bidAmt);
        bytes32 revealHash = keccak256(toHash);
        closedBid memory closedBidOfSender = hashedBids[msg.sender];

        require(revealHash == closedBidOfSender.hash, "Incorrect nonce and/or bid amount!");

        openBid memory revealedBid = openBid(bidAmt, closedBidOfSender.time, msg.sender);
        uint queueSize = bidQueue.length;
        bool inserted = false;
        openBid memory prevBid;
        openBid memory temp;

        for (uint i = 0; i < queueSize; i++) {
            openBid memory currBid = bidQueue[i];
            if (inserted) {
                temp = prevBid;
                prevBid = currBid;
                bidQueue[i] = temp;
            } else if ((bidAmt > currBid.amount) || ((bidAmt == currBid.amount) && (closedBidOfSender.time < currBid.time))) {
                prevBid = currBid;
                bidQueue[i] = revealedBid;
                inserted = true;
            } else {
                // Does nothing
            }
        }

        if (!inserted) { // Adds revealed bid to queue if not yet added
            bidQueue.push(revealedBid);
        } else { // Else adds the last bid back to queue
            bidQueue.push(prevBid);
        }

        // Removes hashed bids from previous list to avoid sender revealing a valid bid more than once
        delete hashedBids[msg.sender];
        delete bidExists[msg.sender];

    }

    // Finds out which is the highest valid bid
        function endRevelation() public{
      //  require(!checkedByOwner);
       uint smallest = bidQueue[0].amount;
       uint index=0;
   for (uint i = 0; i < bidQueue.length; i++) {
      if (bidQueue[i].amount < smallest) {
         smallest = bidQueue[i].amount;
         index=i;
      }
   }

   winner=bidQueue[index].owner;
    }

    // Closes the tender
    function close() public ownerOnly {
        require(checkedByOwner);
        selfdestruct(owner);
    }

    // Changes the details of the Tender project
    function reopenTender(string memory desc, uint biddingDuration, uint revelationDuration, uint depositAmount) public ownerOnly {
        require(checkedByOwner);
        projectDescription = desc;
        biddingEnd = now + (biddingDuration * 1 minutes);
        revelationEnd = biddingEnd + (revelationDuration * 1 minutes);
        deposit = depositAmount;
        checkedByOwner = false;
    }

    // Gets the phase of the Tender bidding event
    function getPhase() public view returns (string memory) {
        if (now < biddingEnd) {
            return 'Bidding';
        } else if (now < revelationEnd) {
            return 'Revelation';
        } else {
            return 'End';
        }
    }

    // Gets details about the Tender project
    function getProjectDetails() public view returns (string memory, uint, uint, uint) {
        return (projectDescription, deposit, biddingEnd, revelationEnd);
    }

    // Gets the result after revelation period
    function getResults() public view returns (address) {
        return (winner);
    }

}
