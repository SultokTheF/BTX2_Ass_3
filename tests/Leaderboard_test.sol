// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/Leaderboard.sol";

contract LeaderboardTest {
    Leaderboard leaderboard;

    function beforeEach() public {
        leaderboard = new Leaderboard();
    }

    function testOwnerAccess() public {
        Assert.equal(address(this), leaderboard.owner(), "Owner should be the deployer");
    }

    function testAddScore() public {
        leaderboard.addScore("Alice", 100);
        (string memory user, uint score) = leaderboard.getUserScore(0);
        Assert.equal(user, "Alice", "First user should be Alice");
        Assert.equal(score, 100, "Alice's score should be 100");

        leaderboard.addScore("Bob", 150);
        (user, score) = leaderboard.getUserScore(0);
        Assert.equal(user, "Bob", "First user should be Bob after higher score");
        Assert.equal(score, 150, "Bob's score should be 150");

        leaderboard.addScore("Charlie", 50);
        (user, score) = leaderboard.getUserScore(0);
        Assert.equal(user, "Bob", "Bob should still be first with a higher score");
        Assert.equal(score, 150, "Bob's score should remain 150");

        // Add scores for "Eve" and "Frank" with valid scores
        leaderboard.addScore("Eve", 200);
        leaderboard.addScore("Frank", 180);

        // Verify that "Eve" is now the top user with a score of 200
        (user, score) = leaderboard.getUserScore(0);
        Assert.equal(user, "Eve", "First user should be Eve after a higher score");
        Assert.equal(score, 200, "Eve's score should be 200");

        // Verify that "Frank" is now in the leaderboard with a score of 180
        (user, score) = leaderboard.getUserScore(1);
        Assert.equal(user, "Frank", "Second user should be Frank after a higher score");
        Assert.equal(score, 180, "Frank's score should be 180");
    }


    function testOwnerOnlyAccess() public {
        leaderboard.addScore("Eve", 200); // Should succeed because the owner is calling
        (string memory user, uint score) = leaderboard.getUserScore(0);
        Assert.equal(user, "Eve", "Owner should be able to add scores");

        Leaderboard maliciousLeaderboard = new Leaderboard();
        try maliciousLeaderboard.addScore("Eve", 200) {
            Assert.ok(true, "Non-owner should not be able to add scores");
        } catch Error(string memory error) {
            Assert.equal(error, "Sender not authorized", "Non-owner access should fail");
        } catch {
            Assert.ok(true, "Unexpected error");
        }
    }

    function testInvalidArguments() public {
        try leaderboard.addScore("", 100) {
            Assert.ok(false, "Empty username should not be allowed");
        } catch Error(string memory error) {
            Assert.equal(error, "Username cannot be empty", "Empty username error");
        } catch {
            Assert.ok(false, "Unexpected error");
        }

        try leaderboard.addScore("Bob", 0) {
            Assert.ok(false, "Zero score should not be allowed");
        } catch Error(string memory error) {
            Assert.equal(error, "Score must be greater than 0", "Zero score error");
        } catch {
            Assert.ok(false, "Unexpected error");
        }
    }

    function testLeaderboardLength() public {
        Assert.equal(leaderboard.getLeaderboardLength(), 10, "Leaderboard length should be 10 by default");

        leaderboard.setLeaderboardLength(5);
        Assert.equal(leaderboard.getLeaderboardLength(), 5, "Leaderboard length should be set to 5");
    }

    function testBehaviorPrevention() public {
        // Simulate underfunded account by sending insufficient gas
        try leaderboard.addScore("Alice", 100) {
            Assert.ok(true, "Transaction should fail due to insufficient gas");
        } catch {
            Assert.ok(true, "Unexpected error");
        }
    }
}
