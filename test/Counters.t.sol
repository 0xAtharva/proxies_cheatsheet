// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Counters.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin/proxy/transparent/ProxyAdmin.sol";


contract CounterTest is Test {
    address deployer = address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
    Counter1 public c1;
    Counter2 public c2;
    Counter1UUPSImplementation public c1UUPSImpl;
    Counter2UUPSImplementation public c2UUPSImpl;
    Counter1_Factory public f1;
    Counter_TransparentProxy public cT;
    Counter_UUPSProxy public cUUPSProxy;

    function setUp() public {
        c1 = new Counter1();
        c2 = new Counter2();
        c1UUPSImpl = new Counter1UUPSImplementation();
        c2UUPSImpl = new Counter2UUPSImplementation();
        f1 = new Counter1_Factory();
        cT = new Counter_TransparentProxy(address(c1),deployer,"");
        cUUPSProxy = new Counter_UUPSProxy(address(c1UUPSImpl),"");
    }

    function test_Clones() public {
        Counter1 c = Counter1(f1.getNewCounter());
        assertEq(c.x(), 0);
        c.increment();
        assertEq(c.x(), 1);
        c.setX(100);
        assertEq(c.x(), 100);
    }

    function test_CounterTransparentProxy() public {
        (,bytes memory x) = address(cT).call(abi.encodeWithSignature("x()"));
        uint256 x1 = abi.decode(x,(uint256));
        assertEq(x1, 0);
        (bool ok,) = address(cT).call(abi.encodeWithSignature("increment()"));
        require(ok,"increment() failed");
        (,bytes memory data) = address(cT).call(abi.encodeWithSignature("x()"));
        uint256 x2 = abi.decode(data,(uint256));
        assertEq(x2, 1);

        address admin = cT.whoAdmin();
        vm.prank(deployer);
        (bool upgraded,) = admin.call(abi.encodeWithSelector(ProxyAdmin.upgradeAndCall.selector, ITransparentUpgradeableProxy(address(cT)),address(c2),""));
        require(upgraded,"upgrade to c2 failed");
        
        (bool ok1,) = address(cT).call(abi.encodeWithSignature("increment_x()"));
        require(ok1,"increment() failed");
        (bool increased,) = address(cT).call(abi.encodeWithSignature("increment_y()"));
        require(increased);
        (,bytes memory total) = address(cT).call(abi.encodeWithSignature("total()"));
        uint256 amt = uint256(bytes32(total));
        assertEq(amt, 5);
    }    

    function test_CounterUUPSProxy() public {
        //test c1UUPSImpl functions
        (,bytes memory data) = address(cUUPSProxy).call(abi.encodeWithSignature("x()"));
        uint256 x = abi.decode(data,(uint256));
        assertEq(x,0);
        (bool success,) = address(cUUPSProxy).call(abi.encodeWithSignature("setX(uint256)",50));
        require(success);
        (bool success1,) = address(cUUPSProxy).call(abi.encodeWithSignature("increment()"));
        require(success1);
        (,bytes memory data1) = address(cUUPSProxy).call(abi.encodeWithSignature("x()"));
        uint256 x1 = abi.decode(data1,(uint256));
        assertEq(x1,51);

        //upgrade to c2UUPSImpl 
        (bool success2,) = address(cUUPSProxy).call(abi.encodeWithSignature("upgradeToAndCall(address,bytes)",address(c2UUPSImpl),""));
        require(success2);

        //test c2UUPSImpl functions
        (,bytes memory data2) = address(cUUPSProxy).call(abi.encodeWithSignature("x()"));
        uint256 x2 = abi.decode(data2,(uint256));
        assertEq(x2,51);
        (bool success3,) = address(cUUPSProxy).call(abi.encodeWithSignature("increment_x()"));
        require(success3);
        (,bytes memory data3) = address(cUUPSProxy).call(abi.encodeWithSignature("x()"));
        uint256 x3 = abi.decode(data3,(uint256));
        assertEq(x3,53);

    }
}

