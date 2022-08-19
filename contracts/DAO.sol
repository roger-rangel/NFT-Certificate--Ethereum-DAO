// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// Import this file to use console.log
import "hardhat/console.sol";

contract DAO {
    // Proposal structure
    struct Proposal {  
        string proposalName;
        uint value;
        address payable proposalCreator;
        bool accepted;
        uint voteCount;
        mapping(address => bool) approvals;
    }

    // proposalCreator, minimumContribution, voters, proposals
    address public proposalCreator;
    string public proposalName;
    uint public minimumContribution;
    mapping(address => bool) public voters;
    uint public votersCount;
    Proposal[] public proposals;

    // constructor (proposalCreator, voter)
    constructor() {
        proposalCreator = msg.sender;
    }

    //Proposal
    function createProposal(string memory name, uint value, address payable recipient) public {
        Proposal storage newProposal = proposals.push();
        newProposal.proposalName = name;
        newProposal.value = value;
        newProposal.proposalCreator = recipient;
        newProposal.accepted = false;
        newProposal.voteCount = 0;

        proposals.push();
    }

    // get Proposal Name
    function setProposalName(string memory _name) external {
        require(
            msg.sender == proposalCreator,
            "You must be the owner to set the name of the Proposal"
        );
        proposalName = _name;
    }

    // contribute to a Proposal
        function contribute() public payable {
        require(msg.value > minimumContribution);

        voters[msg.sender] = true;
        votersCount++;
    }

    // approve Proposal
    function approveProposal(uint index) public {
        Proposal storage proposal = proposals[index];

        require(voters[msg.sender]);
        require(!proposal.approvals[msg.sender]);

        proposal.approvals[msg.sender] = true;
        proposal.voteCount++;
    }

    // complete Proposal 
        function completeProposal(uint index) public {
        Proposal storage proposal = proposals[index];

        require(proposal.voteCount > (votersCount / 2));
        require(!proposal.accepted);

        proposal.proposalCreator.transfer(proposal.value);
        proposal.accepted = true;
    }
}