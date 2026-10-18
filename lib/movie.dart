// PART 1: THE DATA MODEL

class Movie {
  final String title;
  final String genre;
  final int year;
  final double rating;
  final String image; // path of the poster image
  final String overview; // extra: short story line (optional)

  const Movie({
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.image,
    this.overview = '',
  });
}

// Ratings are sample values for the assignment.
final List<Movie> movies = [
  const Movie(
    title: 'Gatto',
    genre: 'Animation',
    year: 2026,
    rating: 7.9,
    image: 'assets/posters/gatto.jpg',
    overview:
        'A little black cat hangs by a thread above the moonlit canals of Venice, and nine lives are not going to be enough.',
  ),
  const Movie(
    title: 'Train to Busan',
    genre: 'Action',
    year: 2016,
    rating: 7.6,
    image: 'assets/posters/train_to_busan.jpg',
    overview:
        'Passengers on a speeding train fight to stay alive when a deadly outbreak spreads from car to car.',
  ),
  const Movie(
    title: 'Self',
    genre: 'Animation',
    year: 2024,
    rating: 7.3,
    image: 'assets/posters/self.jpg',
    overview:
        'A wooden girl wants to belong, and learns what really shines underneath.',
  ),
  const Movie(
    title: 'Lost Ollie',
    genre: 'Adventure',
    year: 2022,
    rating: 7.4,
    image: 'assets/posters/lost_ollie.jpg',
    overview:
        'A lost toy rabbit crosses the countryside to find the boy who left him behind.',
  ),
  const Movie(
    title: 'Deep Sea',
    genre: 'Animation',
    year: 2023,
    rating: 7.2,
    image: 'assets/posters/deep_sea.jpg',
    overview:
        'A girl dives into a dreamlike ocean to face her sadness and say a quiet thank you.',
  ),
  const Movie(
    title: 'The Cat in the Hat',
    genre: 'Fantasy',
    year: 2026,
    rating: 7.8,
    image: 'assets/posters/cat_in_the_hat.jpg',
    overview:
        'One rainy day, two kids and one very mischievous cat. This time it is not just a little mischief.',
  ),
  const Movie(
    title: 'Escape: Psycho Circus',
    genre: 'Horror',
    year: 2015,
    rating: 7.5,
    image: 'assets/posters/escape_psycho_circus.jpg',
    overview:
        'A moonlit ride through a haunted forest where the roller coaster never really stops.',
  ),
  const Movie(
    title: 'Rom',
    genre: 'Drama',
    year: 2020,
    rating: 7.0,
    image: 'assets/posters/rom.jpg',
    overview:
        'Life in a crowded Saigon apartment block, seen through the eyes of a boy who lives by his luck.',
  ),
  const Movie(
    title: 'Canary',
    genre: 'Animation',
    year: 2019,
    rating: 7.0,
    image: 'assets/posters/canary.jpg',
    overview:
        'A tiny boy and his tiny yellow bird join the toughest miners deep underground.',
  ),
  const Movie(
    title: 'Bilal',
    genre: 'Adventure',
    year: 2015,
    rating: 6.9,
    image: 'assets/posters/bilal.jpg',
    overview:
        'A masked young hero crosses the desert and fights for freedom against all odds.',
  ),
  const Movie(
    title: 'Dragonkeeper',
    genre: 'Fantasy',
    year: 2024,
    rating: 6.9,
    image: 'assets/posters/dragonkeeper.jpg',
    overview:
        'A girl is trusted with a dragon egg and must cross the empire to keep the last dragon alive.',
  ),
  const Movie(
    title: 'Ainbo',
    genre: 'Adventure',
    year: 2021,
    rating: 6.6,
    image: 'assets/posters/ainbo.jpg',
    overview:
        'A brave Amazon girl and two spirit guides set out to save the jungle she calls home.',
  ),
];
