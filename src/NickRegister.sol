// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @title NickRegister
 * @dev User nickname register contract
 */
contract NickRegister is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}

    mapping(address account => string nick) private nickByAccount;
    mapping(string nick => address account) private accountByNick;

    /**
     * @dev Trying to get unregistered account nickname
     * @param account Unregistered account
     */
    error AccountNotRegistered(address account);

    /**
     * @dev Trying to get unregistered nickname account
     * @param nick Unregistered nick
     */
    error NickNotRegistered(string nick);

    /**
     * @dev Too short nick
     * @param nick Too short nick
     * @param length Nick length
     * @param correctLength Correct length
     */
    error NickTooShort(string nick, uint8 length, uint8 correctLength);

    /**
     * @dev Too long nick
     * @param nick Too long nick
     * @param length Nick length
     * @param correctLength Correct length
     */
    error NickTooLong(string nick, uint8 length, uint8 correctLength);

    /**
     * @dev Nick already registered
     * @param nick Already registered nick
     */
    error NickAlreadyRegistered(string nick);

    /**
     * @dev Nick successfully registered
     * @param account Nick account
     * @param nick Registered nick
     */
    event SuccessfulNickRegistration(address indexed account, string nick);

    /**
     * @dev Get nick of account
     * @param account Nick account
     * @return nick
     */
    function nickOf(address account) onlyOwner public view returns (string memory) {
        string memory result = nickByAccount[account];
        if (bytes(result).length == 0) {
            revert AccountNotRegistered(account);
        }
        return result;
    }

    /**
     * @dev Get nick of caller
     * @return caller nick
     */
    function nick() external view returns (string memory) {
        return nickOf(msg.sender);
    }
}
