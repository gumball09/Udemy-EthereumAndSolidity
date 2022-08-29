// SPDX-License-Identifier: GPL-3.
// Contract deploying another contract
// The deployed contract's owner is set to an EOA not the contractCreator

pragma solidity >=0.5.0 <0.9.0;

contract A {
    address public ownerA;

    constructor(address EOA) {
        ownerA = EOA;
    }
}

contract Creator {
    address public ownerCreator;
    A[] public deployedA;

    constructor() {
        ownerCreator = msg.sender;
    }

    // deploy another contract
    function deployA() public {
        A new_A_address = new A(msg.sender); // create a new contract A instance
        deployedA.push(new_A_address);
    }
}
