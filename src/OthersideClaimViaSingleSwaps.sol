// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/console.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}

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

interface IERC3156FlashBorrowerUpgradeable {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface NftxVault {
    function flashLoan(
        IERC3156FlashBorrowerUpgradeable receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    function redeem(uint256 amount, uint256[] calldata specificIds)
        external
        returns (uint256[] calldata);

    function mint(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts /* ignored for ERC721 vaults */
    ) external returns (uint256);

    function swap(
        uint256[] calldata tokenIds,
        uint256[] calldata amounts, /* ignored for ERC721 vaults */
        uint256[] calldata specificIds
    ) external returns (uint256[] calldata);
}

interface Otherside {
    function nftOwnerClaimLand(
        uint256[] calldata alphaTokenIds,
        uint256[] calldata betaTokenIds
    ) external;
}

contract OthersideClaimViaSingleSwaps is IERC3156FlashBorrowerUpgradeable {
    address baycNFT = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address baycNftx = 0xEA47B64e1BFCCb773A0420247C0aa0a3C1D2E5C5;
    address otherside; // fill address

    function flash() public {
        // transfer my own ape to this contract
        IERC721(baycNFT).transferFrom(msg.sender, address(this), 8558);
        IERC20(baycNftx).approve(baycNftx, type(uint256).max);

        // flashloan to pay for swaps
        NftxVault(baycNftx).flashLoan(
            IERC3156FlashBorrowerUpgradeable(address(this)),
            baycNftx,
            10 ether, // arbitrary number, just loan enough for the NFTX swaps
            ""
        );
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        console.log("Recieved FL: Amount, Fees", amount, fee);
        console.log("\n");

        IERC721(baycNFT).setApprovalForAll(baycNftx, true);

        uint256[] memory tokenIdtoSwap = new uint256[](1);
        uint256[] memory tokenIdRedeem = new uint256[](1);

        // redeem land here for ape 8558 here
        // Otherside(otherside).nftOwnerClaimLand(tokenIdtoSwap, new uint256[](0));

        tokenIdtoSwap[0] = 8558;
        tokenIdRedeem[0] = 3391;
        NftxVault(baycNftx).swap(
            tokenIdtoSwap,
            new uint256[](0),
            tokenIdRedeem
        );

        // redeem land here for ape 3391 here
        // Otherside(otherside).nftOwnerClaimLand(tokenIdtoSwap, new uint256[](0));

        tokenIdtoSwap[0] = 3391;
        tokenIdRedeem[0] = 2787;
        NftxVault(baycNftx).swap(
            tokenIdtoSwap,
            new uint256[](0),
            tokenIdRedeem
        );

        // redeem land here for ape 2787 here
        // Otherside(otherside).nftOwnerClaimLand(tokenIdtoSwap, new uint256[](0));

        tokenIdtoSwap[0] = 2787;
        tokenIdRedeem[0] = 4755;
        NftxVault(baycNftx).swap(
            tokenIdtoSwap,
            new uint256[](0),
            tokenIdRedeem
        );

        // redeem land here for ape 4755 here
        // Otherside(otherside).nftOwnerClaimLand(tokenIdtoSwap, new uint256[](0));

        tokenIdtoSwap[0] = 4755;
        tokenIdRedeem[0] = 8167;
        NftxVault(baycNftx).swap(
            tokenIdtoSwap,
            new uint256[](0),
            tokenIdRedeem
        );
        // redeem land here for ape 8167 here
        // Otherside(otherside).nftOwnerClaimLand(tokenIdtoSwap, new uint256[](0));

        tokenIdtoSwap[0] = 8167;
        tokenIdRedeem[0] = 8214;
        NftxVault(baycNftx).swap(
            tokenIdtoSwap,
            new uint256[](0),
            tokenIdRedeem
        );

        // redeem land here for ape 8214 here
        // Otherside(otherside).nftOwnerClaimLand(tokenIdtoSwap, new uint256[](0));

        uint256 BaycERC20Balance = IERC20(baycNftx).balanceOf(address(this));

        // can send the ape back to the vault to help pay fees
        // NftxVault(baycNftx).mint(tokenIdtoSwap, new uint256[](0));

        console.log("Fee to pay NFTX", amount - BaycERC20Balance);

        // pay fee here

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
