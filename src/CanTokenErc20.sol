// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.28;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/// @custom:security-contact alexeychub@gmail.com
contract CanTokenErc20 is ERC20, ERC20Permit, Ownable {
    string public constant TOKEN_NAME = "CanToken";

    constructor() ERC20(TOKEN_NAME, "CAN") ERC20Permit(TOKEN_NAME) Ownable(msg.sender) {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 3;
    }
}
