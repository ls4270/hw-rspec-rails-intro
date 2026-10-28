require 'rails_helper'

describe Movie, type: :model do
  it 'returns unsaved movies from TMDb' do
    results = Movie.find_in_tmdb(
      title: 'Olympics',
      release_year: '2000',
      language: 'en'
    )

    expect(results).not_to be_empty
    expect(results.first.title).to eq('Olympics')
    expect(results.first.rating).to eq('R')
    expect(results.first).not_to be_persisted
  end

  describe 'searching TMDb by keyword' do
    it 'calls Faraday to make an HTTP request' do
      expect(Faraday).to receive(:get)
      Movie.find_in_tmdb('https://cs169.org')
    end
  end
end

describe Movie, type: :model do
  it 'excludes movies already saved in the database' do
    Movie.create!(
      title: 'Olympics',
      rating: 'R',
      release_date: '2000-01-01'
    )

    results = Movie.find_in_tmdb(
      title: 'Olympics',
      release_year: '2000',
      language: 'en'
    )

    expect(results.map(&:title)).not_to include('Olympics')
  end
end
