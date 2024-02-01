// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/proxy/Clones.sol";
import "openzeppelin-contracts/proxy/utils/Initializable.sol";

import "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "openzeppelin-contracts/proxy/ERC1967/ERC1967Utils.sol";

import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";

import "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";

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
    uint256 public y;

    function setX(uint256 newNumber) public {
        x = newNumber;
    }

    function increment_x() public {
        x++;
        x++;
    }
    function increment_y() public {
        y++;
        y++;
    }
    function total() view public returns(uint256) {
        return x+y;
    }
}

contract Counter1Factory {
    using Clones for address;

    Counter1 public c = new Counter1();

    function getNewCounter() public returns( address ) {
        return address(c).clone();
    }

}

contract Counter1967Proxy is ERC1967Proxy {
    uint256 public x;
    constructor(address implementation,bytes memory data) ERC1967Proxy(implementation,data) { }

    function upgrade(address _newImplementation) public {
        ERC1967Utils.upgradeToAndCall(_newImplementation,"");
    }

}

contract CounterTransparent is TransparentUpgradeableProxy {
    uint256 public x;

    constructor(address _logic, address initialOwner, bytes memory _data) TransparentUpgradeableProxy(_logic,initialOwner,_data) {}

    function whoAdmin() public returns(address){
        return _proxyAdmin();
    }
}