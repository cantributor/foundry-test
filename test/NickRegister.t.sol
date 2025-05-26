// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {NickRegister} from "../src/NickRegister.sol";

contract NickRegisterTest is Test {
    NickRegister public nickRegister;

    address constant private OWNER = address(101);
    address constant private CALLER = address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);

    function setUp() public {
        nickRegister = new NickRegister(OWNER);
    }

    function test_nicksTotal_RevertWhen_CallerIsNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, CALLER));
        assertEq(nickRegister.nicksTotal(), 0);
    }

    function test_nicksTotal() public {
        vm.prank(address(OWNER));
        assertEq(nickRegister.nicksTotal(), 0);
    }
}
