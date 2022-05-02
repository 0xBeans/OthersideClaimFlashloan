// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/console.sol";
import {OthersideClaimViaSingleSwaps} from "../src/OthersideClaimViaSingleSwaps.sol";

interface Vm {
    function startPrank(address) external;
}

interface IERC721 {
    function setApprovalForAll(address operator, bool _approved) external;
}

contract OthersideClaimViaSingleSwapsTest is DSTest {
    OthersideClaimViaSingleSwaps bot;
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address baycNFT = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    function setUp() public {
        bot = new OthersideClaimViaSingleSwaps();
    }

    function testExample() public {
        vm.startPrank(address(0xA045dfB9b742b06160fac011A27F06d854e80f64));
        IERC721(baycNFT).setApprovalForAll(address(bot), true);

        bot.flash();
    }
}
