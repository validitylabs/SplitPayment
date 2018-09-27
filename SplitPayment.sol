pragma solidity ^0.4.24;

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract SplitPayment is Ownable {
    
    address[] public beneficiaries;
    
    event AddedBeneficiary(address beneficiary);
    
    event RemovedBeneficiary(uint256 indexOfBeneficiary, address beneficiary);
    
    event LogPayout(address beneficiary, uint256 amount);
    
    function addBeneficiary(address _beneficiary) public onlyOwner {
        beneficiaries.push(_beneficiary);
        emit AddedBeneficiary(_beneficiary);
    }
    
    function bulkAddBeneficiaries(address[] _beneficiaries) public onlyOwner {
        uint256 len = beneficiaries.length;
        
        for (uint256 b = 0; b < len; b++) {
            addBeneficiary(_beneficiaries[b]);
        }
    }
    
    function removeBeneficiary(uint256 indexOfBeneficiary) public onlyOwner {
        emit RemovedBeneficiary(indexOfBeneficiary, beneficiaries[indexOfBeneficiary]);

        // unless the to be deleted index is not last -> move last one here
        if (indexOfBeneficiary < beneficiaries.length - 1) {
            beneficiaries[indexOfBeneficiary] = beneficiaries[beneficiaries.length - 1];
        }

        // if to be deleted index is in range -> decrease length by one
        if(indexOfBeneficiary < beneficiaries.length) {
            beneficiaries.length--;
        }
    }
    
    function() public payable {
        uint256 len = beneficiaries.length;
        uint256 amount = msg.value / len;
        
        for (uint256 b = 0; b < len; b++) {
            beneficiaries[b].transfer(amount);
            emit LogPayout(beneficiaries[b], amount);
        }
    }
    
    function retrieveLostEth() public onlyOwner {
        owner().transfer(address(this).balance);
    }
    
    function getNumberOfBeneficiaries() public view returns (uint256 length) {
        return beneficiaries.length;
    }
}
