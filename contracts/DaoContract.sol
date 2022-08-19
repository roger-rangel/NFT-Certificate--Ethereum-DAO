// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// Import this file to use console.log
import "hardhat/console.sol";

// interface where the balance of the total tokens that you own are shown
interface interfaceDao {
    function showBalanceTokens(address, uint256) external view returns (uint256);
}

contract Dao {
    // Proposal structure
    struct Proposal {  
        string proposalName;
        uint256 greenVote;
        uint256 redVote;
        bool accepted;
        address[] eligibleVoter;
        bool active;
        uint256 proposalId;
        uint maxVoteCount;
        bool countedVoteCount;
        uint voteEndTime;
        mapping(address => bool) alreadyVoted;
    }

    // creator, an index for each proposal each time a new Proposal is created, tokens Id, interface
    address public creator;
    uint indexProposal;
    uint256[] public tokens;
    interfaceDao contractDao;

    constructor() {
        creator = msg.sender;
        indexProposal = 1;
        contractDao = interfaceDao();
        tokens = [];
    }

    mapping(uint256 => Proposal) public Proposals;

    event newProposal(
        address proposalCreator,
        string proposalName,
        uint256 proposalId,
        uint maxVoteCount
    );

    event newVote(
        address voter,
        uint256 greenVote,
        uint256 redVote,
        uint256 proposal,
        bool votedGreen
    );

    event votesCounted(
        uint256 proposalId,
        bool accepted
    );

    //Proposal
    function createProposal(uint minimum, string memory name, uint value, address payable recipient) public {
        Proposal storage newProposal = proposals.push();
        newProposal.proposalName = name;
        newProposal.value = value;
        newProposal.proposalCreator = recipient;
        newProposal.accepted = false;
        newProposal.voteCount = 0;
        minimumContribution = minimum;
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