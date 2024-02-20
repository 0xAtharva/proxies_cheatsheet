// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/proxy/Clones.sol";
import "openzeppelin-up/proxy/utils/Initializable.sol";

import "openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import "openzeppelin/proxy/ERC1967/ERC1967Utils.sol";

import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin/proxy/transparent/ProxyAdmin.sol";

import "openzeppelin/proxy/utils/UUPSUpgradeable.sol";

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

contract Counter1UUPSImplementation is UUPSUpgradeable {
    uint256 public x;

    function setX(uint256 newNumber) public {
        x = newNumber;
    }
    function increment() public {
        x++;
    }

    function _authorizeUpgrade(address newImplementation) internal override {}

}

contract Counter2UUPSImplementation is UUPSUpgradeable {
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
    function _authorizeUpgrade(address newImplementation) internal override {}
}

contract Counter1_Factory {
    using Clones for address;

    Counter1 public c = new Counter1();

    function getNewCounter() public returns( address ) {
        return address(c).clone();
    }
}


contract Counter_TransparentProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic, 
        address initialOwner, 
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic,initialOwner,_data){}

    function whoAdmin() public returns(address){
        return _proxyAdmin();
    }
    receive() external payable {}
}

contract Counter_UUPSProxy is ERC1967Proxy {
    constructor(address implementation, bytes memory _data) ERC1967Proxy(implementation,_data) {

    }

    // function upgrade_logic(address _impl, bytes memory _data) public {
    //     (bool upgraded,) = address(ERC1967Utils.getImplementation()).call(abi.encodeWithSignature("upgradeToAndCall(address,bytes)",_impl, _data));
    //     require(upgraded,"upgrade failed");
    // }

    receive() external payable {}

}