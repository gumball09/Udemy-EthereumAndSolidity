// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;
        players.push(payable(manager));
    }

    receive() external payable {
        require(msg.sender != manager);
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender)); // convert plain address to payable address
    }

    function getBalance() public view returns (uint) {
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public {
        // require(msg.sender == manager);
        require(players.length >= 10);

        uint r = random();
        address payable winner;

        uint index = r % players.length;
        winner = players[index];

        uint totalBalance = getBalance();
        uint managerFees = totalBalance * 10 / 100;
        payable(manager).transfer(managerFees);
        winner.transfer(totalBalance - managerFees);

        // reallocate the players to 0 length
        players = new address payable[](0); // reset the array players
    }
}
