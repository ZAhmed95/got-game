# test users with profiles
user1 = User.create(
  username: 'zia',
  password: '1234'
)
profile1 = Profile.create(
  user_id: user1.id,
  first_name: 'Zaheen',
  last_name: 'Ahmed',
  email: 'zia1840@gmail.com',
  birth_date: '1995-01-30'
)

user2 = User.create(
  username: 'test',
  password: 'abcd'
)
profile2 = Profile.create(
  user_id: user2.id,
  first_name: 'John',
  last_name: 'Doe',
  email: 'test@gmail.com',
  birth_date: '2000-01-01'
)

# test posts with comments
post1 = Post.create(
  user_id: user1.id,
  game_id: 8173,
  game_title: 'Overwatch',
  title: 'Overwatch sucks',
  content: "This game is stupid. I got headshot by a widowmaker from across the map. Quitting the game. Uninstalling. Sucks for you Blizzard, you'll miss my money when I'm gone.",
)

post1_comment1 = Comment.create(
  user_id: user1.id,
  post_id: post1.id,
  comment: "I totally agree. Overwatch is for filthy casuals.",
)

post1_comment2 = Comment.create(
  user_id: user2.id,
  post_id: post1.id,
  comment: "I STRONGLY disagree with this statement. This is BULLSHIT!!!11",
)