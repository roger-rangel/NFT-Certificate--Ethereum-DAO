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

    event latestProposal(
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

    // creator, an index for each proposal each time a new Proposal is created, token Id, interface of the Dao contract
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

    // eligibility to Vote 
    modifier onlyEligibleVoter(address _voter) {
        uint balance = daoToken.balanceOf(_voter);
        require(balance > 0);
        _;
    }

    // check token Balance 
    function getTokenBalance(address _votingCandidate) private view returns (bool){
        uint256 userBalance = ERC20(daoToken).balanceOf(_votingCandidate);
        if (userBalance > 0) {
            return true;
        } else {
            return false;
        }
    }

    // create a Proposal
    function createProposal(address[] memory _eligibleVoter, string memory _name) public {
        require(getTokenBalance(msg.sender), "Make sure you hold a Token in order to submit a Proposal");

        Proposal storage newProposal = Proposals[indexProposal];
        newProposal.proposalName = _name;
        newProposal.eligibleVoter = _eligibleVoter;
        newProposal.active = true;
        newProposal.proposalId = indexProposal;
        newProposal.voteEndTime = block.number + 20;
        newProposal.totalVotes = _eligibleVoter.length;

        emit latestProposal(msg.sender, _name, indexProposal, _eligibleVoter.length);
        indexProposal++;
    }


    // change Proposal Name
    function changeProposalName(string memory _name) external {
        require(msg.sender == creator, "You must be the owner to set the name of the Proposal");
        string proposalName = _name;
    }

    // vote for a Proposal
        function vote(uint _id, bool _vote) public {
        require(Proposals[_id].active, "This Proposal is not active");
        require(onlyEligibleVoter(msg.sender), "You don't have permission to vote for this Proposal yet");
        require(!Proposals[_id].alreadyVoted[msg.sender], "You have already voted on this Proposal");
        require(block.number <= Proposals[_id].voteEndTime, "The time granted for voting has expired");

        Proposal storage votesProposal = Proposals[_id];

        if(_vote) {
            votesProposal.greenVote++;
        }else{
            votesProposal.redVote++;
        }

        votesProposal.alreadyVoted[msg.sender] = true;

        emit newVote(votesProposal.greenVote, votesProposal.redVote, msg.sender, _id, _vote);
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