// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// ---------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// ---------------------------------------------

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed t, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// inherit interface
contract Cryptos is ERC20Interface {
    // token name
    string public name = 'Cryptos';

    // token symbol
    string public symbol = 'CRPT';

    // token decimals (how divisible a token can be, range 0 - 18)
    uint public decimals = 0; // 18 is the most used

    // total # of tokens
    uint public override totalSupply; // override totalSupply() in the interface

    // founder (holder of all tokens)
    address public founder;

    // mapping stores # of tokens in each address
    // key is address, value is uint
    mapping(address => uint) public balances;
    // balances[0x1111...] = 100;

    // nested mapping
    // 1st key is the acc which will approve the acc in the 2nd key to use the uint value of tokens in the 1st acc
    // 1st key is address of token holder
    // 2nd key is address of acc allowed to transfer balance from token holder
    mapping(address => mapping(address => uint)) allowed;
    // 0x1111.... (owner) allows 0x2222... (spender) withdraw 100 tokens from 0x1111
    // allowed[0x111...][0x222...] = 100;

    // constructor
    constructor() {
        totalSupply = 1000000;
        founder = msg.sender; // deployer
        balances[founder] = totalSupply;
    }

    // --------------------------------
    // manadatory fns of ERC20 standard 
    // Must implement balanceOf, totalSupply, transfer to be partially-compliant to ERC20 standards
    // --------------------------------

    // return token balance of each address in mapping
    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    // transfer a # of tokens from acc that calls it and possesses to a recipient
    // make the token TRANSFERRABLE
    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens; // add tokens to recipient
        balances[msg.sender] -= tokens; // subtract sent tokens from sender

        emit Transfer(msg.sender, to, tokens);
        
        return true; // REVERT ON FAILURE instead of returning false
    }

    // -----------------------------
    // Implement the remaining fns to become fully-compliant
    // -----------------------------

    // return the allowance
    function allowance(address tokenOwner, address spender) view public override returns (uint) {
        return allowed[tokenOwner][spender];
    }

    // approve to set the allowance to be spent by a spender
    function approve(address spender, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens);
        require(tokens >= 0);

        allowed[msg.sender][spender] = tokens; 

        emit Approval(msg.sender, spender, tokens);

        return true; // REVERT ON FAILURE
    }

    // transfer tokens from holder's acc to another acc
    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        // msg.sender is the acc approved by from acc
        require(allowed[from][msg.sender] >= tokens);
        require(balances[from] >= tokens);

        // update # tokens
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;

        // transfer tokens to recipient
        balances[to] += tokens;

        emit Transfer(from, to, tokens);

        return true; // REVERT ON FAILURE
    }
}
