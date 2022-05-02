// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/console.sol";
import {OthersideClaimViaFlashloan} from "../src/OthersideClaimViaFlashloan.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);

    function setApprovalForAll(address operator, bool _approved) external;

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract OthersideClaimViaFlashloanTest is DSTest {
    OthersideClaimViaFlashloan bot;

    function setUp() public {
        bot = new OthersideClaimViaFlashloan();
    }

    function testExample() public {
        bot.flash();
    }
}
