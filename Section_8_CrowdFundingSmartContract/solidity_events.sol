// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Token {
    event Transfer(address _to, uint _value);

    function transfer(address payable _to, uint _value) public {
        // The function's body
        // ...

        emit Transfer(_to, _value);
    }
}
