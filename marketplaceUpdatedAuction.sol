// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyMarketPlace {
    uint nftHolders;
    uint nftSources;
    uint totalAvailableNFTs = 0;

    struct tokenInfo {
        uint id;
        address owner;
        uint price;
        address NFTSource;
        bool isListed;
        bool availableForAuction;
    }

    mapping(address => mapping(uint => bool)) isListed;
    mapping(address => tokenInfo[]) listedNFTs;

    mapping(uint => address) allOwners;
    mapping(address => bool) isNewOwner;

    mapping(uint => address) allNFTsources;
    mapping(address => bool) isNewNFTsource;

    function isNFTlisted(
        uint tokenID,
        address _NFTaddress
    ) public view returns (bool) {
        require(isListed[_NFTaddress][tokenID] == true, "Token Not Exists");
        return true;
    }

    function listNFT(uint tokenID, uint _price, address _NFTaddress) public {
        require(
            IERC721(_NFTaddress).ownerOf(tokenID) == msg.sender,
            "Invalid User"
        );
        require(isListed[_NFTaddress][tokenID] == false, "Already Minted");

        listedNFTs[msg.sender].push(
            tokenInfo(tokenID, msg.sender, _price, _NFTaddress, true, false)
        );
        isListed[_NFTaddress][tokenID] = true;
        totalAvailableNFTs++;

        if (!isNewOwner[msg.sender]) {
            allOwners[nftHolders] = msg.sender;
            isNewOwner[msg.sender] = true;
            nftHolders++;
        }

        if (!isNewNFTsource[_NFTaddress]) {
            allNFTsources[nftSources] = msg.sender;
            isNewNFTsource[_NFTaddress] = true;
            nftSources++;
        }
    }

    function isListedForAuction(
        uint tokenID,
        address _NFTaddress,
        address _tokenOwner
    ) public view returns (bool) {
        tokenInfo[] memory tempList = listedNFTs[_tokenOwner];

        for (uint i = 0; i < tempList.length; i++) {
            if (
                tempList[i].NFTSource == _NFTaddress &&
                tempList[i].availableForAuction == true &&
                tempList[i].id == tokenID
            ) {
                return true;
            }
        }
        return false;
    }

    function changeListedForAuctionStatus(
        uint tokenID,
        address _NFTaddress,
        address _tokenOwner,
        bool status
    ) public returns (bool) {
        tokenInfo[] storage tempList = listedNFTs[_tokenOwner];

        for (uint i = 0; i < tempList.length; i++) {
            // if(tempList[i].availableForAuction == false){

            if (
                tempList[i].NFTSource == _NFTaddress &&
                tempList[i].id == tokenID
            ) {
                tempList[i].availableForAuction = status;

                return true;
            }
            // }
        }
        return false;
    }

    function buyNFT(
        uint tokenID,
        address _NFTaddress,
        address _tokenOwner
    ) public payable {
        require(isListed[_NFTaddress][tokenID] == true, "Token Not Exists");
        require(
            msg.sender != IERC721(_NFTaddress).ownerOf(tokenID),
            "User should Not be the Owner"
        );
        require(
            _tokenOwner == IERC721(_NFTaddress).ownerOf(tokenID),
            "tokenOwner must be the token owner"
        );

        tokenInfo[] storage tempList = listedNFTs[_tokenOwner];

        for (uint i = 0; i < tempList.length; i++) {
            if (tempList[i].availableForAuction == true) {
                revert("Currently Listed for Auction");
            }

            if (
                tempList[i].NFTSource == _NFTaddress &&
                tempList[i].id == tokenID
            ) {
                require(msg.value >= tempList[i].price, "Low Value Pass");
                isListed[_NFTaddress][tokenID] = false;
                break;
            }
        }

        IERC721(_NFTaddress).transferFrom(
            IERC721(_NFTaddress).ownerOf(tokenID),
            msg.sender,
            tokenID
        );
        payable(IERC721(_NFTaddress).ownerOf(tokenID)).transfer(msg.value);

        unlistgiven(_NFTaddress, tokenID);
    }

    function updatePriceOfNFT(
        uint tokenID,
        uint _price,
        address _NFTaddress
    ) public {
        require(isNewOwner[msg.sender], "Invalid user");
        require(isListed[_NFTaddress][tokenID] == true, "Token Not Exists");
        require(
            IERC721(_NFTaddress).ownerOf(tokenID) == msg.sender,
            "Invalid User"
        );

        tokenInfo[] storage tempList = listedNFTs[msg.sender];

        for (uint i = 0; i < tempList.length; i++) {
            if (
                tempList[i].NFTSource == _NFTaddress &&
                tempList[i].id == tokenID
            ) {
                tempList[i].price = _price;
                break;
            }
        }
    }

    function unlistNFT(uint tokenId, address _NFTaddress) public {
        require(isNewOwner[msg.sender], "Invalid user");
        require(
            IERC721(_NFTaddress).ownerOf(tokenId) == msg.sender,
            "Invalid User"
        );
        require(isListed[_NFTaddress][tokenId] == true, "not Listed");

        tokenInfo[] storage tempList = listedNFTs[msg.sender];

        for (uint i = 0; i < tempList.length; i++) {
            if (
                tempList[i].NFTSource == _NFTaddress &&
                tempList[i].id == tokenId
            ) tempList[i].isListed = false;
            isListed[_NFTaddress][tokenId] = false;
        }

        unlistgiven(_NFTaddress, tokenId);
    }

    function unlistgiven(address _NFTaddress, uint tokenId) public {
        tokenInfo[] storage tempList = listedNFTs[msg.sender];

        for (uint i = 0; i < tempList.length; i++) {
            if (
                tempList[i].isListed == false &&
                isListed[_NFTaddress][tokenId] == false
            ) {
                tempList[i] = tempList[tempList.length - 1];
                tempList.pop();
                totalAvailableNFTs--;
                break;
            }
        }
    }

    function nftListOfUser(
        address _address
    ) public view returns (tokenInfo[] memory) {
        uint x = 0;
        for (uint i = 0; i < nftHolders; i++) {
            tokenInfo[] memory tempList = listedNFTs[allOwners[i]];

            for (uint j = 0; j < tempList.length; j++) {
                if (
                    tempList[j].owner == _address &&
                    tempList[j].isListed == true
                ) {
                    x++;
                }
            }
        }

        uint y;
        tokenInfo[] memory IsTemp = new tokenInfo[](x);

        for (uint i = 0; i < nftHolders; i++) {
            tokenInfo[] memory tempList = listedNFTs[allOwners[i]];

            for (uint j = 0; j < tempList.length; j++) {
                if (
                    tempList[j].owner == _address &&
                    tempList[j].isListed == true
                ) {
                    IsTemp[y] = tempList[j];
                    y++;
                }
            }
        }
        return IsTemp;
    }

    function listAllAvailableNFTs() public view returns (tokenInfo[] memory) {
        tokenInfo[] memory IsTemp = new tokenInfo[](totalAvailableNFTs);
        uint x = 0;
        for (uint i = 0; i < nftHolders; i++) {
            tokenInfo[] memory tempList = listedNFTs[allOwners[i]];
            for (uint j = 0; j < listedNFTs[allOwners[i]].length; j++) {
                IsTemp[x] = tempList[j];
                x++;
            }
        }
        return IsTemp;
    }

    function listAllofNFTsource(
        address _NFTaddress
    ) public view returns (tokenInfo[] memory) {
        uint x = 0;
        for (uint i = 0; i < nftHolders; i++) {
            tokenInfo[] memory tempList = listedNFTs[allOwners[i]];

            for (uint j = 0; j < tempList.length; j++) {
                if (
                    tempList[j].NFTSource == _NFTaddress &&
                    tempList[j].isListed == true
                ) {
                    x++;
                }
            }
        }

        uint y;
        tokenInfo[] memory IsTemp = new tokenInfo[](x);

        for (uint i = 0; i < nftHolders; i++) {
            tokenInfo[] memory tempList = listedNFTs[allOwners[i]];

            for (uint j = 0; j < tempList.length; j++) {
                if (
                    tempList[j].NFTSource == _NFTaddress &&
                    tempList[j].isListed == true
                ) {
                    IsTemp[y] = tempList[j];
                    y++;
                }
            }
        }
        return IsTemp;
    }
}

