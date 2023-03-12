This Solidity contract named **MyMarketPlace** is a **marketplace** for buying and selling non-fungible tokens (NFTs) on the Ethereum blockchain.

## The contract provides the following functionalities:

- **listNFT(uint tokenID, uint _price, address _NFTaddress):** Allows an NFT owner to list their token on the marketplace by specifying the tokenID, _price, and _NFTaddress.

- **isNFTlisted(uint tokenID, address _NFTaddress):** Returns whether an NFT with the given tokenID and _NFTaddress is listed on the marketplace.

- **isListedForAuction(uint tokenID, address _NFTaddress, address _tokenOwner):** Returns whether an NFT with the given tokenID, _NFTaddress, and _tokenOwner is currently listed for auction.

- **changeListedForAuctionStatus(uint tokenID, address _NFTaddress, address _tokenOwner, bool status): ** Allows an NFT owner to change the listed-for-auction status of their token.

- **buyNFT(uint tokenID, address _NFTaddress, address _tokenOwner):** Allows a user to buy an NFT with the given tokenID, _NFTaddress, and _tokenOwner from the marketplace. The user must pay the listed price for the NFT, which is transferred to the NFT owner, and the NFT is transferred to the buyer.

- **updatePriceOfNFT(uint tokenID, uint _price, address _NFTaddress):** Allows an NFT owner to update the price of their listed NFT with the given tokenID and _NFTaddress.

- **unlistNFT(uint tokenId, address _NFTaddress):** Allows an NFT owner to unlist their NFT with the given tokenId and _NFTaddress from the marketplace.

The contract also includes various **mappings** and **structs** to store information about listed NFTs and their owners and sources, as well as functions to check whether an NFT is already listed or whether a user is a new owner.
