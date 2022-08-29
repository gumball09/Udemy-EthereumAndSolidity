// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract CrowdFunding {
    // mapping the address and value sent by msg.sender to hash table
    mapping(address => uint) public contributors;

    // the manager/ admin of campaign
    address public admin;

    // no of contributors
    uint public noOfContributors;

    // min contribution
    uint public mininumContribution;

    // deadline
    uint public deadline; // timestamp in secs;

    // monetary goal
    uint public goal;

    // amt raised
    uint public raisedAmount;

    // struct for spending request
    struct Request {
        string description;
        address payable recipient;
        uint value; // in wei
        bool completed;
        uint noOfVoters; // no of contributors voting for this request
        mapping(address => bool) voters;
    }

    // Cannot store mappings in arrays in latest solidity so we have to use mapping as a hash table itself
    // var holdings multiple requests
    // key is the no of requests
    // value is the Request
    mapping(uint => Request) public requests;

    // counter of number of requests
    uint public numRequests;

    // events registering transaction outcome as logs on the blockchain
    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);

    // modifier
    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin can call this function!");
        _;
    }

    constructor(uint _goal, uint _deadline) {
        // set goal
        goal = _goal;

        // set deadline
        deadline = block.timestamp + _deadline; // _deadline in secs
        
        // set minimum contribution
        mininumContribution = 100 wei;

        // set admin (contract deployer)
        admin = msg.sender;
    }

    // contribute eth directly without calling the contribute() fn
    // once this receive() fn is called, it will redirect to contribute() fn
    receive() external payable {
        contribute();
    }

    // contribute eth to campaign
    function contribute() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value >= mininumContribution, "Minimum contribution not met");

        // check if the contributor is in the hash table
        if (contributors[msg.sender] == 0) {
            noOfContributors++; // increment 1 if not in
        }

        contributors[msg.sender] += msg.value;

        // add the current value received by the campaign to the total amt raised
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }

    // get contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // refund the contributor if goal not reached
    function getRefund() public {
        require(block.timestamp > deadline && raisedAmount < goal, "Deadline has not passed or goal has been reached");
        require(contributors[msg.sender] > 0, "You are not the contributor"); // contributor has positive balance

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        recipient.transfer(value);

        // payable(msg.sender).transfer(contributors[msg.sender]);

        // reset the contributor's amt to 0
        contributors[msg.sender] = 0;
    }

    // spending request initiated by admin
    // must be voted by contributors
    // only succeed if votes > 50%;
    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin {
        // struct containing mapping so must be declared as storage
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        emit CreateRequestEvent(_description, _recipient, _value);
    }

    // vote for spending request
    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0, "You must be a contributor to vote!");

        // work on a request saved in storage (not on a copy)
        Request storage thisRequest = requests[_requestNo];

        require(thisRequest.voters[msg.sender] == false, "You have already voted!");
        thisRequest.voters[msg.sender] = true; // marks the user has already voted
        thisRequest.noOfVoters++;
    }

    // transfer the money of campaign to supplier or vendor
    // only active when a spending request requirement is met
    function makePayment(uint _requestNo) public onlyAdmin {
        // can only make a payment if goal reached
        require(raisedAmount >= goal, "Goal not reached");
        
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "The request has already been completed!");

        // check if at least 50% contributors have voted for the request
        require(thisRequest.noOfVoters > noOfContributors / 2); // 50% voted for this request

        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
    }
}
