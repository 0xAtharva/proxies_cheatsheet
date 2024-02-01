// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Counter1, Counter2, Counter1Factory, Counter1967Proxy, CounterTransparent} from "../src/Counters.sol";
import "openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";


contract CounterTest is Test {
    address deployer = address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
    Counter1 public c1;
    Counter2 public c2;
    Counter1Factory public f1;
    Counter1967Proxy public c1967Proxy;
    CounterTransparent public cT;

    function setUp() public {
        c1 = new Counter1();
        c2 = new Counter2();
        f1 = new Counter1Factory();
        c1967Proxy = new Counter1967Proxy(address(c1),"");
        cT = new CounterTransparent(address(c1),deployer,"");
    }

    function test_Clones() public {
        Counter1 c = Counter1(f1.getNewCounter());
        assertEq(c.x(), 0);
        c.increment();
        assertEq(c.x(), 1);
        c.setX(100);
        assertEq(c.x(), 100);
    }

    function test_Counter1967Proxy() public {
        (bool ok,) = address(c1967Proxy).call(abi.encodeWithSignature("increment()"));
        require(ok,"increment() failed");
        (,bytes memory data) = address(c1967Proxy).call(abi.encodeWithSignature("x()"));
        uint256 x = uint256(bytes32(data));
        assertEq(x, 1);

        (bool upgraded,) = address(c1967Proxy).call(abi.encodeWithSignature("upgrade(address)",address(c2)));
        require(upgraded,"upgrade to c2 failed");
        
        (bool ok1,) = address(c1967Proxy).call(abi.encodeWithSignature("increment_x()"));
        require(ok1,"increment() failed");
        address(c1967Proxy).call(abi.encodeWithSignature("increment_y()"));
        (,bytes memory total) = address(c1967Proxy).call(abi.encodeWithSignature("total()"));
        uint256 amt = uint256(bytes32(total));
        assertEq(amt, 5);
    }

    function test_CounterTransparent() public {
        assertEq(cT.x(), 0);
        (bool ok,) = address(cT).call(abi.encodeWithSignature("increment()"));
        require(ok,"increment() failed");
        (,bytes memory data) = address(cT).call(abi.encodeWithSignature("x()"));
        uint256 x = uint256(bytes32(data));
        assertEq(x, 1);

        address admin = cT.whoAdmin();
        vm.prank(deployer);
        (bool upgraded,) = admin.call(abi.encodeWithSelector(ProxyAdmin.upgradeAndCall.selector, ITransparentUpgradeableProxy(address(cT)),address(c2),""));
        require(upgraded,"upgrade to c2 failed");
        
        (bool ok1,) = address(cT).call(abi.encodeWithSignature("increment_x()"));
        require(ok1,"increment() failed");
        address(cT).call(abi.encodeWithSignature("increment_y()"));
        (,bytes memory total) = address(cT).call(abi.encodeWithSignature("total()"));
        uint256 amt = uint256(bytes32(total));
        assertEq(amt, 5);
    }    
}

