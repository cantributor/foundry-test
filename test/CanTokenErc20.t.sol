// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";

import {CanTokenErc20} from "../src/CanTokenErc20.sol";

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Errors} from "../lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";
import {IERC20Permit} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {MessageHashUtils} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract CanTokenErc20Test is Test {
    CanTokenErc20 public canTokenErc20;

    address private constant OWNER = address(1);
    uint256 private constant USER_PRIVATE_KEY = 0xACE101;
    address private immutable USER1 = vm.addr(USER_PRIVATE_KEY);
    address private constant USER2 = address(2);

    function setUp() public {
        vm.prank(address(OWNER));
        canTokenErc20 = new CanTokenErc20();

        vm.label(OWNER, "OWNER");
        vm.label(USER1, "USER1");
        vm.label(USER2, "USER2");
    }

    function test_balanceOf() public view {
        assertEq(1_000_000, canTokenErc20.balanceOf(OWNER));
    }

    function test_transfer_Successful() public {
        assertEq(0, canTokenErc20.balanceOf(USER1));

        vm.prank(address(OWNER));
        canTokenErc20.transfer(USER1, 1000);

        assertEq(1000, canTokenErc20.balanceOf(USER1));
    }

    function test_transferFrom_RevertWhen_ERC20InsufficientAllowance() public {
        assertEq(0, canTokenErc20.balanceOf(USER1));

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, USER1, 0, 1000));
        vm.prank(address(USER1));
        canTokenErc20.transferFrom(OWNER, USER1, 1000);
    }

    function test_permit_Successful() public {
        vm.prank(address(OWNER));
        canTokenErc20.transfer(USER1, 101);
        assertEq(101, canTokenErc20.balanceOf(USER1));

        GaslessTokenTransfer gaslessTokenTransfer = new GaslessTokenTransfer();
        uint256 deadline = block.timestamp + 60;
        bytes32 permitHash = util_createPermitHash(
            canTokenErc20.DOMAIN_SEPARATOR(),
            USER1,
            address(gaslessTokenTransfer),
            101,
            deadline,
            canTokenErc20.nonces(USER1)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(USER_PRIVATE_KEY, permitHash);
        gaslessTokenTransfer.send(address(canTokenErc20), USER1, USER2, 100, 1, deadline, v, r, s);

        assertEq(0, canTokenErc20.balanceOf(USER1));
        assertEq(100, canTokenErc20.balanceOf(USER2));
        assertEq(1, canTokenErc20.balanceOf(address(this))); // fee
    }

    function util_createPermitHash(
        bytes32 tokenDomainSeparator,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint256 nonce
    ) private pure returns (bytes32) {
        bytes32 PERMIT_TYPEHASH =
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
        bytes32 hash = MessageHashUtils.toTypedDataHash(tokenDomainSeparator, structHash);
        return hash;
    }
}

contract GaslessTokenTransfer {
    function send(
        address token,
        address sender,
        address receiver,
        uint256 amount,
        uint256 fee,
        uint256 deadline,
        // Permit signature
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Permit
        IERC20Permit(token).permit(sender, address(this), amount + fee, deadline, v, r, s);
        // Send amount to receiver
        IERC20(token).transferFrom(sender, receiver, amount);
        // Take fee - send fee to msg.sender
        IERC20(token).transferFrom(sender, msg.sender, fee);
    }
}
