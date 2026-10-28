class Movie < ActiveRecord::Base
  def self.find_in_tmdb(search)
    # Keep compatibility with the introductory Faraday test.
    return Faraday.get(search) if search.is_a?(String)

    title = search[:title].to_s.strip
    return [] if title.empty?

    api_key = ENV.fetch('TMDB_API_KEY', 'test_key')
    query = { api_key: api_key, query: title }

    year = search[:release_year].to_s.strip
    query[:year] = year unless year.empty?

    language = search[:language].to_s
    query[:language] = 'en-US' if language == 'en'

    response = Faraday.get(
      'https://api.themoviedb.org/3/search/movie', query
    )
    return [] unless response.status == 200

    data = JSON.parse(response.body)
    results = data.fetch('results', [])

    results.filter_map do |item|
      movie_title = item['title']
      next if movie_title.blank?

      release_date = item['release_date'].presence

      # Avoid showing movies already saved locally.
      already_saved = Movie.exists?(
        title: movie_title, release_date: release_date
      )
      next if already_saved

      Movie.new(
        title: movie_title,
        rating: 'R',
        description: item['overview'].to_s,
        release_date: release_date
      )
    end
  end

  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end
