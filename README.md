# VoteRight - Decentralized Voting System

A secure, transparent, and censorship-resistant voting platform built with Solidity for Ethereum and EVM-compatible blockchains.

## 🌟 Features

- **Transparent Voting**: All votes are recorded on-chain and publicly verifiable
- **One Vote Per Address**: Cryptographically enforced through smart contract logic
- **Time-Bounded Polls**: Set specific start and end times for voting periods
- **Flexible Poll Options**: Support for 2-10 voting options per poll
- **Immutable Records**: Once cast, votes cannot be changed or deleted
- **Gas Optimized**: Uses custom errors and efficient storage patterns
- **Event Emissions**: All actions emit events for easy off-chain tracking

## 🏗️ Architecture

The smart contract provides the following main functions:

### Core Functions
1. **createPoll**: Create a new poll with options and timeframe
2. **castVote**: Cast a vote for a specific option
3. **closePoll**: Close a poll early (creator only)

### View Functions
- **getPoll**: Retrieve all poll details
- **hasVoted**: Check if an address has voted
- **getVoterChoice**: See what option an address voted for
- **getUserPolls**: Get all polls created by an address
- **getVoteRecord**: Get complete vote record for a voter
- **isPollOpen**: Check if voting is currently active

### Data Structures

**Poll Struct**
- Stores poll metadata (description, options, timestamps)
- Tracks vote counts for each option
- Maps voters to their choices
- Records total votes and active status

**VoteRecord Struct**
- Records voter address, poll ID, option choice, and timestamp
- Provides immutable proof of voting



## 🔐 Security Considerations

- **One Vote Per Address**: Enforced through `hasVoted` mapping
- **Time Validation**: Votes can only be cast within the specified timeframe
- **Authority Control**: Only poll creator can close polls early
- **Immutable Votes**: Once cast, votes cannot be changed
- **Reentrancy Protection**: No external calls that could be exploited
- **Gas Optimization**: Custom errors save gas compared to string reverts

## 🛠️ Contract Constraints

- **Options**: 2-10 per poll
- **Description**: Maximum 280 characters
- **Solidity Version**: 0.8.20 or higher
- **Vote Period**: Must have valid startTime < endTime

## 📊 Custom Errors

| Error | Description |
|-------|-------------|
| `InvalidOptionCount` | Poll must have 2-10 options |
| `InvalidTimeRange` | Start time must be before end time |
| `DescriptionTooLong` | Description exceeds 280 characters |
| `PollNotActive` | Poll has been closed |
| `PollNotStarted` | Voting period hasn't begun |
| `PollEnded` | Voting period has ended |
| `InvalidOption` | Selected option doesn't exist |
| `Unauthorized` | Not the poll creator |
| `AlreadyVoted` | Address has already voted |
| `PollDoesNotExist` | Poll ID doesn't exist |

## 📡 Events

```solidity
event PollCreated(uint256 indexed pollId, address indexed creator, string description, uint256 startTime, uint256 endTime);
event VoteCast(uint256 indexed pollId, address indexed voter, uint8 optionIndex, uint256 timestamp);
event PollClosed(uint256 indexed pollId, address indexed closer);
```

## 💰 Gas Estimates (Approximate)

| Function | Gas Cost |
|----------|----------|
| createPoll (3 options) | ~250,000 |
| castVote | ~80,000 |
| closePoll | ~30,000 |
| getPoll | Free (view) |
| hasVoted | Free (view) |

## 🌐 Supported Networks

- Ethereum Mainnet
- Sepolia Testnet
- Goerli Testnet
- Polygon
- Arbitrum
- Optimism
- Base
- Any EVM-compatible chain

## Contract image
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d78fa961-a7be-47ae-810f-c41d9e2e00ce" />

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Ethers.js Documentation](https://docs.ethers.org/)


**Built with ❤️ on Ethereum**
