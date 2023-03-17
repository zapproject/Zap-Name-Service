// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDomainRecords {
    function getRecord(string memory name) external view returns (string memory);
}

contract DomainRecordsAPI {
    IDomainRecords private domainRecordsContract;

    constructor(address _domainRecordsContractAddress) {
        domainRecordsContract = IDomainRecords(_domainRecordsContractAddress);
    }

    function getRecord(string memory name) public view returns (string memory) {
        return domainRecordsContract.getRecord(name);
    }
}
