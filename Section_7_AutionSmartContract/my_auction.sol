// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// Contract interface to deploy thousands of auction contracts
contract AuctionCreator {
    Auction[] public auctions;

    function createAuction() public {
        Auction newAuction = new Auction(msg.sender); // call the Auction constructor
        auctions.push(newAuction);
    }
}

contract Auction {
    address payable public owner;

    // start and end time of aution based on block
    uint public startBlock;
    uint public endBlock;

    // IPFS hash holds the info of item being auctioned
    string ipfsHash;

    // auction state
    enum State { Started, Running, Ended, Cancelled }
    State public auctionState;

    // selling price of item
    uint public highestBindingBid;

    // highest bidder who pays 
    address payable public highestBidder;

    // mapping stores the address (key) and amt (value) into hash table
    mapping(address => uint) public bids;

    // increment amount that the auction automally increments
    uint bidIncrement;

    constructor(address EOA) {
        // set the owner
        owner = payable(EOA);

        // set the auction state
        auctionState = State.Running;

        // calc the start and end time of auction based on block #
        // set the auction to run for ONE WEEK
        startBlock = block.number;
        uint secondsInAWeek = 60 * 60 * 24 * 7; // total of secs in a week
        uint secondsABlockGenerated = 15; // total of secs for a new block to be generated
        uint noBlocksGeneratedInAWeek = secondsInAWeek / secondsABlockGenerated; // total of blocks generated in a week
        endBlock = startBlock + noBlocksGeneratedInAWeek;

        // item ipfs
        ipfsHash = '';

        // bid increment
        bidIncrement = 1000000000000000000; // 1 ether
    }

    // modifiers
    modifier notOwner() {
        require(msg.sender != owner);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // modifier checking the time validity of auction
    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }

    function min(uint a, uint b) pure internal returns (uint) {
        return a > b ? b : a;
    }

    // cancel auction
    function cancelAuction() public onlyOwner {
        auctionState = State.Cancelled;
    }

    // place bid
    function placeBid() public payable notOwner afterStart beforeEnd {
        // auction must be running to place bid
        require(auctionState == State.Running);

        // bid amt >= 100 wei
        require(msg.value >= 100);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]) {
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    // finalize auction
    function finalizeAuction() public {
        require(auctionState == State.Cancelled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint value;

        // if auction is cancalled
        if(auctionState == State.Cancelled) {
            // every bidder requests the money back
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }
        // if aunction is ended (expires after a period of time)
        else {
            // if auction is finalized by owner
            if(msg.sender == owner) {
                recipient = owner;
                value = highestBindingBid;
            } else { // if auction is not finalized by the owner but a bidder requesting his own bidded money
                // if the bidder requesting this is the highest bidder
                if(msg.sender == highestBidder) {
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                } else { // neither owner nor highest bidder
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        // reset bids of recipient to 0 to prevent him to withdraw his bids more than once
        // bid value resetted to 0 means he is not a bidder anymore
        bids[recipient] = 0;

        // transfer the amt to the recipient
        recipient.transfer(value);
    }
}


