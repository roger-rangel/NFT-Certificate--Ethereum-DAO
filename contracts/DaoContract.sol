// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// Import this file to use console.log
import "hardhat/console.sol";

// ERC20 token
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface interfaceDao {
    function viewOwner() external returns (address);
    function changeSymbol(string memory _symbol) external;
    function changeName(string memory _name) external;
    function tokenBalance(address, uint) external view returns (uint);
}

contract Dao {

    event newProposal(
        address proposalCreator,
        string proposalName,
        uint proposalId,
        uint totalVotes
    );

    event newVote(
        address voter,
        uint greenVote,
        uint redVote,
        uint proposal,
        bool votedGreen
    );

    event votesCounted(
        uint256 proposalId,
        bool accepted
    );

    // Proposal structure
    struct Proposal {  
        string proposalName;
        uint greenVote;
        uint redVote;
        bool accepted;
        address[] eligibleVoter;
        bool active;
        uint256 proposalId;
        uint totalVotes;
        bool countedAllVotes;
        uint voteEndTime;
        mapping(address => bool) alreadyVoted;
    }

    // creator, an index for each proposal each time a new Proposal is created, tokens Id, interface
    address public creator;
    uint indexProposal;
    uint256[] public daoToken;
    interfaceDao contractDao;

    constructor() {
        creator = msg.sender;
        indexProposal = 1;
        contractDao = interfaceDao();
        daoToken = [];
    }

    mapping(uint256 => Proposal) public Proposals;

    // check token Balance 
    function getTokenBalance(address _votingCandidate) private view returns (bool){
        uint256 userBalance = ERC20(daoToken).balanceOf(_votingCandidate);
        if (userBalance > 0) {
            return true;
        } else {
            return false;
        }
    }

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