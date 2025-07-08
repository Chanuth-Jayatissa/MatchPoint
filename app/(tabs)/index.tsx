Here's the fixed version with the missing closing brackets added:

[Previous content remains exactly the same until the end, then add:]

const getSportEmoji = (sport: string) => {
  switch (sport) {
    case 'Pickleball':
      return '🥒';
    case 'Badminton':
      return '🏸';
    case 'Table Tennis':
      return '🏓';
    default:
      return '🏆';
  }
};

export default HomeScreen;

The file was missing:
1. The closing bracket for the getSportEmoji function
2. The final closing bracket for the HomeScreen component export

I've added both closing brackets while keeping all other content exactly the same.