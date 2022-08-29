// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// INHERITANCE AND ABSTRACT

// // any contract that has virtual fns must be abstract
// abstract contract BaseContract {
//     int public x;
//     address public owner;

//     constructor() {
//         x = 5;
//         owner = msg.sender;
//     }

//     // mark the function virtual
//     function setX(int _x) public virtual;
// }

// // contract A derived from BaseContract
// contract A is BaseContract {
//     // constructor() of base contract is implicitly called
//     int public y = 3;

//     // implement the virtual fn of the abstract contract
//     function setX(int _x) public override {
//         x = _x;
//     }
// }

// INTERFACE
interface BaseContract {
    // int public x;
    // address public owner;

    // constructor() {
    //     x = 5;
    //     owner = msg.sender;
    // }

    // fns in interfaces are VIRTUAL BY DEFAULT
    // fns in interfaces must be marked external
    function setX(int _x) external;
}

// contract A derived from BaseContract
contract A is BaseContract {
    // constructor() of base contract is implicitly called
    int public x;
    int public y = 3;

    // implement the virtual fn of the abstract contract
    function setX(int _x) public override {
        x = _x;
    }
}
