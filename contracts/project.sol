// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VoteRight
 * @dev Decentralized voting system with time-bound polls and one vote per address
 */
contract VoteRight {
    
    struct Poll {
        uint256 pollId;
        address creator;
        string description;
        string[] options;
        uint256[] voteCounts;
        uint256 startTime;
        uint256 endTime;
        uint256 totalVotes;
        bool isActive;
        mapping(address => bool) hasVoted;
        mapping(address => uint8) voterChoice;
    }
    
    struct VoteRecord {
        address voter;
        uint256 pollId;
        uint8 optionIndex;
        uint256 timestamp;
    }
    
    // State variables
    mapping(uint256 => Poll) public polls;
    mapping(address => uint256[]) public userPolls;
    mapping(address => mapping(uint256 => VoteRecord)) public voteRecords;
    
    uint256 public pollCounter;
    
    // Events
    event PollCreated(
        uint256 indexed pollId,
        address indexed creator,
        string description,
        uint256 startTime,
        uint256 endTime
    );
    
    event VoteCast(
        uint256 indexed pollId,
        address indexed voter,
        uint8 optionIndex,
        uint256 timestamp
    );
    
    event PollClosed(uint256 indexed pollId, address indexed closer);
    
    // Custom errors
    error InvalidOptionCount();
    error InvalidTimeRange();
    error DescriptionTooLong();
    error PollNotActive();
    error PollNotStarted();
    error PollEnded();
    error InvalidOption();
    error Unauthorized();
    error AlreadyVoted();
    error PollDoesNotExist();
    
    /**
     * @dev Create a new poll
     * @param _description Poll description (max 280 characters)
     * @param _options Array of voting options (2-10 options)
     * @param _startTime Unix timestamp for poll start
     * @param _endTime Unix timestamp for poll end
     */
    function createPoll(
        string memory _description,
        string[] memory _options,
        uint256 _startTime,
        uint256 _endTime
    ) external returns (uint256) {
        if (_options.length < 2 || _options.length > 10) {
            revert InvalidOptionCount();
        }
        if (_startTime >= _endTime) {
            revert InvalidTimeRange();
        }
        if (bytes(_description).length > 280) {
            revert DescriptionTooLong();
        }
        
        uint256 newPollId = pollCounter++;
        Poll storage newPoll = polls[newPollId];
        
        newPoll.pollId = newPollId;
        newPoll.creator = msg.sender;
        newPoll.description = _description;
        newPoll.options = _options;
        newPoll.voteCounts = new uint256[](_options.length);
        newPoll.startTime = _startTime;
        newPoll.endTime = _endTime;
        newPoll.totalVotes = 0;
        newPoll.isActive = true;
        
        userPolls[msg.sender].push(newPollId);
        
        emit PollCreated(newPollId, msg.sender, _description, _startTime, _endTime);
        
        return newPollId;
    }
    
    /**
     * @dev Cast a vote on a poll
     * @param _pollId The ID of the poll
     * @param _optionIndex The index of the option to vote for
     */
    function castVote(uint256 _pollId, uint8 _optionIndex) external {
        Poll storage poll = polls[_pollId];
        
        if (poll.creator == address(0)) {
            revert PollDoesNotExist();
        }
        if (!poll.isActive) {
            revert PollNotActive();
        }
        if (block.timestamp < poll.startTime) {
            revert PollNotStarted();
        }
        if (block.timestamp > poll.endTime) {
            revert PollEnded();
        }
        if (_optionIndex >= poll.options.length) {
            revert InvalidOption();
        }
        if (poll.hasVoted[msg.sender]) {
            revert AlreadyVoted();
        }
        
        poll.hasVoted[msg.sender] = true;
        poll.voterChoice[msg.sender] = _optionIndex;
        poll.voteCounts[_optionIndex]++;
        poll.totalVotes++;
        
        voteRecords[msg.sender][_pollId] = VoteRecord({
            voter: msg.sender,
            pollId: _pollId,
            optionIndex: _optionIndex,
            timestamp: block.timestamp
        });
        
        emit VoteCast(_pollId, msg.sender, _optionIndex, block.timestamp);
    }
    
    /**
     * @dev Close a poll (only creator can close)
     * @param _pollId The ID of the poll to close
     */
    function closePoll(uint256 _pollId) external {
        Poll storage poll = polls[_pollId];
        
        if (poll.creator != msg.sender) {
            revert Unauthorized();
        }
        if (!poll.isActive) {
            revert PollNotActive();
        }
        
        poll.isActive = false;
        
        emit PollClosed(_pollId, msg.sender);
    }
    
    /**
     * @dev Get poll details
     * @param _pollId The ID of the poll
     */
    function getPoll(uint256 _pollId) external view returns (
        uint256 pollId,
        address creator,
        string memory description,
        string[] memory options,
        uint256[] memory voteCounts,
        uint256 startTime,
        uint256 endTime,
        uint256 totalVotes,
        bool isActive
    ) {
        Poll storage poll = polls[_pollId];
        
        return (
            poll.pollId,
            poll.creator,
            poll.description,
            poll.options,
            poll.voteCounts,
            poll.startTime,
            poll.endTime,
            poll.totalVotes,
            poll.isActive
        );
    }
    
    /**
     * @dev Check if an address has voted on a poll
     * @param _pollId The ID of the poll
     * @param _voter The address to check
     */
    function hasVoted(uint256 _pollId, address _voter) external view returns (bool) {
        return polls[_pollId].hasVoted[_voter];
    }
    
    /**
     * @dev Get the vote choice of an address
     * @param _pollId The ID of the poll
     * @param _voter The address to check
     */
    function getVoterChoice(uint256 _pollId, address _voter) external view returns (uint8) {
        if (!polls[_pollId].hasVoted[_voter]) {
            revert InvalidOption();
        }
        return polls[_pollId].voterChoice[_voter];
    }
    
    /**
     * @dev Get all polls created by an address
     * @param _creator The address of the creator
     */
    function getUserPolls(address _creator) external view returns (uint256[] memory) {
        return userPolls[_creator];
    }
    
    /**
     * @dev Get vote record for a voter on a specific poll
     * @param _voter The address of the voter
     * @param _pollId The ID of the poll
     */
    function getVoteRecord(address _voter, uint256 _pollId) external view returns (VoteRecord memory) {
        return voteRecords[_voter][_pollId];
    }
    
    /**
     * @dev Check if a poll is currently active and accepting votes
     * @param _pollId The ID of the poll
     */
    function isPollOpen(uint256 _pollId) external view returns (bool) {
        Poll storage poll = polls[_pollId];
        return poll.isActive && 
               block.timestamp >= poll.startTime && 
               block.timestamp <= poll.endTime;
    }
}