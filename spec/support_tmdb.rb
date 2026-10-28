RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, /api\.themoviedb\.org/).to_return(
      status: 200,
      body: {
        page: 1,
        results: [
          {
            id: 71608,
            title: "Olympics",
            release_date: "2000-01-01",
            overview: "Sample movie",
            original_language: "en"
          }
        ]
      }.then { |data| JSON.generate(data) },
      headers: {'Content-Type' => 'application/json'}
    )
  end
end
