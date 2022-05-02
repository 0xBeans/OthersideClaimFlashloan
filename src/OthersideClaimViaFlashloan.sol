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
}

interface Otherside {
    function nftOwnerClaimLand(
        uint256[] calldata alphaTokenIds,
        uint256[] calldata betaTokenIds
    ) external;
}

// This is a little gross but it gets the job done
contract OthersideClaimViaFlashloan is IERC3156FlashBorrowerUpgradeable {
    address baycNFT = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    address baycNftx = 0xEA47B64e1BFCCb773A0420247C0aa0a3C1D2E5C5;
    address otherside; // fill address

    function flash() public {
        IERC20(baycNftx).approve(baycNftx, type(uint256).max);

        NftxVault(baycNftx).flashLoan(
            IERC3156FlashBorrowerUpgradeable(address(this)),
            baycNftx,
            10 ether, // loan enough tokens to claim all 5 apes in the vault
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

        // redeem all 5 apes
        NftxVault(baycNftx).redeem(5, new uint256[](0));
        console.log("Redeeming 5 Apes \n");

        uint256 BaycNftBalance = IERC721(baycNFT).balanceOf(address(this));
        uint256 BaycERC20Balance = IERC20(baycNftx).balanceOf(address(this));

        console.log("Cost to redeem 5 apes", amount - BaycERC20Balance);
        console.log("initial balance BAYC NFTs", BaycNftBalance);
        console.log("initial balance BAYC ERC20", BaycERC20Balance);
        console.log("\n");

        // get tokenIds of apes in array, we can probably hard code this
        // since we know what apes are in the vault already
        uint256[] memory tokenIds = new uint256[](BaycNftBalance);

        for (uint256 i; i < IERC721(baycNFT).balanceOf(address(this)); ++i) {
            uint256 tokenId = IERC721(baycNFT).tokenOfOwnerByIndex(
                address(this),
                i
            );

            tokenIds[i] = tokenId;
        }

        // redeem lands for all apes like:
        // Otherside(otherside).nftOwnerClaimLand(tokenIds, new uint256[](0));

        // send apes back to the vault
        IERC721(baycNFT).setApprovalForAll(baycNftx, true);
        // mint new tokens
        NftxVault(baycNftx).mint(tokenIds, new uint256[](0));

        BaycNftBalance = IERC721(baycNFT).balanceOf(address(this));
        BaycERC20Balance = IERC20(baycNftx).balanceOf(address(this));

        console.log(
            "current balance BAYC NFTs after sending to vault",
            BaycNftBalance
        );
        console.log(
            "current balance BAYC ERC20s after minting",
            BaycERC20Balance
        );
        console.log("Fee to pay NFTX", amount - BaycERC20Balance);

        // Buy Sushiswap tokens to repay the fee here or send your own ape to vault to help pay fee

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
