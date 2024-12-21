// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationalToolReviewRewards {
    struct Reviewer {
        uint256 reviewCount;
        uint256 rewardsEarned;
    }

    struct Review {
        address reviewer;
        string appName;
        string reviewText;
        uint256 timestamp;
        bool approved;
    }

    address public owner;
    uint256 public rewardAmount;
    Review[] public reviews;
    mapping(address => Reviewer) public reviewers;

    event ReviewSubmitted(address indexed reviewer, uint256 reviewId);
    event ReviewApproved(address indexed reviewer, uint256 reviewId);
    event RewardsClaimed(address indexed reviewer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(uint256 _rewardAmount) {
        owner = msg.sender;
        rewardAmount = _rewardAmount; // Reward amount per approved review
    }

    // Submit a review
    function submitReview(string calldata appName, string calldata reviewText) external {
        require(bytes(appName).length > 0, "App name is required");
        require(bytes(reviewText).length > 0, "Review text is required");

        reviews.push(Review({
            reviewer: msg.sender,
            appName: appName,
            reviewText: reviewText,
            timestamp: block.timestamp,
            approved: false
        }));

        emit ReviewSubmitted(msg.sender, reviews.length - 1);
    }

    // Approve a review (onlyOwner)
    function approveReview(uint256 reviewId) external onlyOwner {
        require(reviewId < reviews.length, "Invalid review ID");
        Review storage review = reviews[reviewId];
        require(!review.approved, "Review is already approved");

        review.approved = true;

        // Reward the reviewer
        Reviewer storage reviewer = reviewers[review.reviewer];
        reviewer.reviewCount++;
        reviewer.rewardsEarned += rewardAmount;

        emit ReviewApproved(review.reviewer, reviewId);
    }

    // Claim rewards
    function claimRewards() external {
        Reviewer storage reviewer = reviewers[msg.sender];

        uint256 rewards = reviewer.rewardsEarned;
        require(rewards > 0, "No rewards to claim");

        reviewer.rewardsEarned = 0;

        // Transfer rewards (mock transfer, replace with ERC20 for token support)
        payable(msg.sender).transfer(rewards);

        emit RewardsClaimed(msg.sender, rewards);
    }

    // Owner can fund the contract
    function fundContract() external payable onlyOwner {}

    // Update reward amount
    function updateRewardAmount(uint256 _newRewardAmount) external onlyOwner {
        rewardAmount = _newRewardAmount;
    }

    // Fallback function to accept Ether
    receive() external payable {}
}