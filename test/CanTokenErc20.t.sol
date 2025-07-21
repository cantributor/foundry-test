// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";

import {CanTokenErc20} from "../src/CanTokenErc20.sol";

import {IERC20Errors} from "../lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";

contract CanTokenErc20Test is Test {
    CanTokenErc20 public canTokenErc20;

    address private constant OWNER = address(1);
    address private immutable USER = address(this);

    function setUp() public {
        vm.prank(address(OWNER));
        canTokenErc20 = new CanTokenErc20();
    }

    function test_balanceOf() public view {
        assertEq(1_000_000, canTokenErc20.balanceOf(OWNER));
    }

    function test_transfer_Successful() public {
        assertEq(0, canTokenErc20.balanceOf(USER));

        vm.prank(address(OWNER));
        canTokenErc20.transfer(USER, 1000);

        assertEq(1000, canTokenErc20.balanceOf(USER));
    }

    function test_transferFrom_RevertWhen_ERC20InsufficientAllowance() public {
        assertEq(0, canTokenErc20.balanceOf(USER));

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, USER, 0, 1000));
        canTokenErc20.transferFrom(OWNER, USER, 1000);
    }
}
