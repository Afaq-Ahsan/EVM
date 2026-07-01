# Electronic Voting Machine (EVM)

A DAO-based Electronic Voting Machine (EVM) smart contract that enables decentralized and transparent elections through multi-owner governance.

## How It Works

### 1. Initialize the Contract
The contract requires **3 owners** to manage the election process.

### 2. Add Candidates
- Any one of the three owners can propose a new candidate for the election.
- The candidate must then be approved by the other **2 owners** before becoming eligible for the election.

### 3. Start the Voting Process
- Once the candidates are approved, any owner can start the voting process.
- The voting duration is specified in **seconds**.

Examples:
- **1 hour** = `3600` seconds
- **24 hours (1 day)** = `86400` seconds

### 4. Cast Votes
- Voters can cast their votes only during the active voting period (between the voting start and end time).
- Votes submitted outside this time window will be rejected.

### 5. End the Election
After the voting period has ended:

1. An owner calls the `endVoting()` function.
2. The owner then calls the `fetchResult()` function to calculate the election results.
3. Finally, call the `winnerId()` function to retrieve the ID of the winning candidate.

## Workflow

1. Deploy the contract with **3 owners**.
2. An owner proposes a candidate.
3. The remaining two owners approve the candidate.
4. An owner starts the voting period by specifying the duration in seconds.
5. Eligible voters cast their votes during the active voting period.
6. After the voting period ends, an owner calls `endVoting()`.
7. Call `fetchResult()` to process the results.
8. Call `winnerId()` to obtain the ID of the winning candidate.

This multi-signature approval mechanism ensures that no single owner can manipulate the election process, making the voting system decentralized, transparent, and secure.
