// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Leaderboard {

  // person who deploys contract is the owner
  address public owner;

  // lists top 10 users
  uint public leaderboardLength = 10;

  // create an array of Users
  mapping (uint => User) public leaderboard;
    
  // each user has a username and score
  struct User {
    string user;
    uint score;
  }
    
  constructor() {
    owner = msg.sender;
  }

  // allows owner only
  modifier onlyOwner(){
    require(owner == msg.sender, "Sender not authorized");
    _;
  }

  // owner calls to update leaderboard
  function addScore(string memory user, uint score) public onlyOwner returns (bool) {
    require(bytes(user).length > 0, "Username cannot be empty");
    require(score > 0, "Score must be greater than 0");
    
    // if the score is too low, don't update
    if (leaderboard[leaderboardLength-1].score >= score) return false;

    // loop through the leaderboard
    for (uint i=0; i<leaderboardLength; i++) {
      // find where to insert the new score
      if (leaderboard[i].score < score) {

        // shift leaderboard
        User memory currentUser = leaderboard[i];
        for (uint j=i+1; j<leaderboardLength+1; j++) {
          User memory nextUser = leaderboard[j];
          leaderboard[j] = currentUser;
          currentUser = nextUser;
        }

        // insert
        leaderboard[i] = User({
          user: user,
          score: score
        });

        // delete last from list
        delete leaderboard[leaderboardLength];

        return true;
      }
    }
  }

  // Getter for leaderboard length
  function getLeaderboardLength() public view returns (uint) {
    return leaderboardLength;
  }

  // Getter for a specific user's score
  function getUserScore(uint index) public view returns (string memory, uint) {
    require(index < leaderboardLength, "Index out of range");
    User memory user = leaderboard[index];
    return (user.user, user.score);
  }

  // Setter for changing the leaderboard length
  function setLeaderboardLength(uint newLength) public onlyOwner {
    leaderboardLength = newLength;
  }
}
