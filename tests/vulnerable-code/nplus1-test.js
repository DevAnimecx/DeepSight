// Test Fixture: N+1 Query Performance Issue
// Expected: performance.md agent should flag as High

const User = require('./models/User');
const Post = require('./models/Post');

async function getUsersWithPostCounts() {
  // VULNERABILITY: N+1 query pattern
  const users = await User.findAll();
  
  for (const user of users) {
    // Executes one query PER user
    const postCount = await Post.count({
      where: { userId: user.id }
    });
    user.postCount = postCount;
  }
  
  return users;
}

module.exports = { getUsersWithPostCounts };
