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
        uint proposal,
        bool votedGreen,
        address voter,
        uint greenVote,
        uint redVote
    );

    event votesCounted(
        uint256 proposalId,
        bool accepted
    );

    // Token Structure
    struct Token {  
        string tokenName;
        uint tokenId;
        uint tokenBalance;
    }

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
        contractDao = interfaceDao(0x88B48F654c30e99bc2e4A1559b4Dcf1aD93FA656);
        daoToken = [82973708039240629251272792125261330690652406198626706840055742852139281647264];
        creator = msg.sender;
        indexProposal = 1;
    }

    mapping(uint256 => Proposal) public Proposals;

    mapping(uint256 => Token) public Tokens;

    // make a Proposal
    function makeProposal(address[] memory _eligibleVoter, string memory _name) public {
        require(getTokenBalance(msg.sender), "Make sure you hold an Electric Token in order to submit a Proposal");

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
    function changeProposalName(uint _id, string memory _name) external {
        require(msg.sender == creator, "You must be the owner to set the name of the Proposal");

        Proposal storage thisProposal = Proposals[_id];
        thisProposal.proposalName = _name;
    }

    // check token Balance 
    function getTokenBalance(address _votingCandidate) private view returns (bool) {
        for(uint i = 0; i < daoToken.length; i++){
            if(contractDao.tokenBalance(_votingCandidate, daoToken[i]) >= 1){
                return true;
            }
        }
        return false;
    }

    // vote for a Proposal
        function vote(uint _id, bool _vote) public {
        require(Proposals[_id].active, "This Proposal is not active");
        require(allowedToVote(_id, msg.sender), "You don't have permission to vote for this Proposal yet");
        require(!Proposals[_id].alreadyVoted[msg.sender], "You have already voted on this Proposal");
        require(block.number <= Proposals[_id].voteEndTime, "The time granted for voting has expired");

        Proposal storage votesProposal = Proposals[_id];
        _vote ? votesProposal.greenVote++ : votesProposal.redVote++;

        votesProposal.alreadyVoted[msg.sender] = true;
        emit newVote(_id, _vote, msg.sender, votesProposal.greenVote, votesProposal.redVote);
    }

    // count all the votes
    function votesCounter(uint _id) public {
        require(msg.sender == creator, "Only the creator of this DAO can count all the votes for submission");
        require(Proposals[_id].active, "This Proposal is not active or does not exist yet");
        require(block.number > Proposals[_id].voteEndTime, "The deadline for voting has not expired yet");
        require(!Proposals[_id].countedAllVotes, "All votes were already counted");

        Proposal storage votesProposal = Proposals[_id];
        
        if(Proposals[_id].redVote < Proposals[_id].greenVote){
            votesProposal.accepted = true;            
        }

        votesProposal.countedAllVotes = true;

        emit votesCounted(_id, votesProposal.accepted);
    }

    // asign valid Tokens
    function addTokenId(uint _tokenId) public {
        require(msg.sender == creator, "Only Owner Can Add Tokens");

        daoToken.push(_tokenId);
    }

    // change name of Token
    function changeTokenName(uint _id, string memory _name) external {
        require(msg.sender == creator, "You must be the owner to set the name of this Token");

        Token storage token = Tokens[_id];
        token.tokenName = _name;
    }

    // check if user is allowed to cast a vote
    function allowedToVote(uint256 _id, address _voter) private view returns (bool) {
        for (uint256 i = 0; i < Proposals[_id].eligibleVoter.length; i++) {
            if (Proposals[_id].eligibleVoter[i] == _voter) {
            return true;
            }
        }
        return false;
    }
}