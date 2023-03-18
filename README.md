## Zap Name Service Smart Contract
The Zap Name Service is an ERC-721 compliant smart contract that allows users to register and manage domain names. The contract requires users to own a minimum of 10,000 ZAP tokens to register a domain name.

``Ownership of ZAP tokens is verified using the ERC-20 interface of the token contract, and the contract checks the balance and allowance of the caller before allowing the registration of a new domain name.``

Once a domain name is registered, the user can set a record for that domain, which is stored in the contract. Users can also retrieve the record for a domain and get the address associated with a domain name

The smart contract also allows users to get a list of all registered domain names, and the corresponding token IDs.

```Functions```
Constructor(string _tld, address _zapTokenAddress)
This function initializes the contract with a TLD (top-level domain) string and the address of the ZAP token contract.

`register(string name)`

This function registers a new domain name. It checks if the domain name is already registered and if the name is valid. If the checks pass, the function verifies that the caller has a balance of at least 10,000 ZAP tokens and the contract has an allowance of ZAP tokens to transfer the amount required for registration. The function then creates a new ERC-721 token and sets its token URI to a JSON representation of the domain name and other relevant information. The function also stores the address of the caller as the owner of the domain name and returns the token ID of the newly created token.

`price(string name)`
This function returns the price required to register a domain name, based on its length.

`getAddress(string name)`
This function returns the address of the owner of a domain name.

`setRecord(string name, string record)`
This function sets the record for a domain name.

`getRecord(string name)`
This function returns the record associated with a domain name.

`getAllNames()`
This function returns a list of all registered domain names and their corresponding token IDs.

`withdraw()`
This function allows the owner of the contract to withdraw the balance of the contract in ZAP tokens.
The smart contract also has several mappings and variables that store domain name information, such as the owner of a domain, the record associated with a domain, and the token ID of a domain name.

# DomainRecordsAPI Smart Contract Developer Guide
Overview
The DomainRecordsAPI contract is an Ethereum smart contract that abstracts domain records and exposes them as an API. It takes the address of another smart contract that implements the IDomainRecords interface, which exposes a getRecord function that returns the record for a given domain name.

#### Usage
#########To use the DomainRecordsAPI contract, you'll need to follow these steps:

`Deploy the smart contract that implements the IDomainRecords interface and provides the getRecord function to retrieve domain records. This contract should keep track of domain records and provide an interface to retrieve them. For example, you could use the DomainRecords contract from the previous example.
`
`Deploy the DomainRecordsAPI contract and pass the address of the IDomainRecords contract to the constructor. This will allow the DomainRecordsAPI contract to access the domain records stored in the IDomainRecords contract.`
`
``Call the getRecord function in the DomainRecordsAPI contract, passing the domain name as an argument. This function will return the record associated with the domain name, as retrieved from the IDomainRecords contract.``

####### Here's an example of how to use the DomainRecordsAPI contract in Solidity code:

```js
Copy code
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDomainRecords {
    function getRecord(string memory name) external view returns (string memory);
}

contract MyContract {
    IDomainRecords private domainRecordsContract;
    DomainRecordsAPI private domainRecordsAPI;

    constructor(address _domainRecordsContractAddress) {
        domainRecordsContract = IDomainRecords(_domainRecordsContractAddress);
        domainRecordsAPI = new DomainRecordsAPI(_domainRecordsContractAddress);
    }

    function getDomainRecord(string memory name) public view returns (string memory) {
        // Get the domain record using the IDomainRecords contract
        string memory record = domainRecordsContract.getRecord(name);

        // Alternatively, get the domain record using the DomainRecordsAPI contract
        //string memory record = domainRecordsAPI.getRecord(name);

        return record;
    }
}```
In this example, the MyContract contract takes the address of the IDomainRecords contract as an argument and stores it in a private variable called domainRecordsContract. It also creates a new DomainRecordsAPI contract, passing the address of the IDomainRecords contract to the constructor, and stores it in a private variable called domainRecordsAPI.

The getDomainRecord function in the MyContract contract demonstrates two ways to retrieve a domain record:

By calling the getRecord function in the IDomainRecords contract, using the domainRecordsContract variable.

By calling the getRecord function in the DomainRecordsAPI contract, using the domainRecordsAPI variable.

Both methods will return the same result: the record associated with the given domain name. However, the second method provides an abstraction layer that makes it easier to access domain records, as it exposes the getRecord function as an API endpoint that can be called by other smart contracts.
