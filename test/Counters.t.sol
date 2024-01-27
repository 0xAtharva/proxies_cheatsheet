// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Counter1, Counter2, CounterUpgradable, Counter1Factory} from "../src/Counters.sol";

contract CounterTest is Test {
    Counter1 public c1;
    Counter2 public c2;
    Counter1Factory public f1;
    CounterUpgradable public cUp;

    function setUp() public {
        c1 = new Counter1();
        c2 = new Counter2();
        f1 = new Counter1Factory();
        cUp = new CounterUpgradable(address(c1),"");
    }

    function test_CounterUpgradable() public {
        (bool ok,) = address(cUp).call(abi.encodeWithSignature("increment()"));
        require(ok,"increment() failed");
        (,bytes memory data) = address(cUp).call(abi.encodeWithSignature("x()"));
        uint256 x = uint256(bytes32(data));
        assertEq(x, 1);

        (bool upgraded,) = address(cUp).call(abi.encodeWithSignature("upgrade(address)",address(c2)));
        require(upgraded,"upgrade to c2 failed");
        
        (bool ok1,) = address(cUp).call(abi.encodeWithSignature("increment()"));
        require(ok1,"increment() failed");
        (,bytes memory data1) = address(cUp).call(abi.encodeWithSignature("x()"));
        uint256 y = uint256(bytes32(data1));
        assertEq(y, 3);
    }

    function test_Increment() public {
        Counter1 c = Counter1(f1.getNewCounter());
        assertEq(c.x(), 0);
        c.increment();
        assertEq(c.x(), 1);
        c.setX(100);
        assertEq(c.x(), 100);
    }
}

