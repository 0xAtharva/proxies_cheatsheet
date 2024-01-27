// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Clones} from "openzeppelin-contracts/proxy/Clones.sol";
import {ERC1967Utils} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Utils.sol";

contract Counter1 {
    uint256 public x;

    function setX(uint256 newNumber) public {
        x = newNumber;
    }

    function increment() public {
        x++;
    }
}

contract Counter2 {
    uint256 public x;

    function setX(uint256 newNumber) public {
        x = newNumber;
    }

    function increment() public {
        x++;
        x++;
    }
}

contract CounterUpgradable is ERC1967Proxy {
    uint256 public x;
    constructor(address implementation,bytes memory data) ERC1967Proxy(implementation,data) { }

    function upgrade(address _newImplementation) public {
        ERC1967Utils.upgradeToAndCall(_newImplementation,"");
    }

}

contract Counter1Factory {
    using Clones for address;

    Counter1 public c = new Counter1();

    function getNewCounter() public returns( address ) {
        return address(c).clone();
    }

}
