# IGist

IGist is a command line tool used to search your gists and starred gists by keyword of gist description. All your gists will be indexed using simple inversed index algorithm. And the index data is saved locally (~/.igist).

## Installation

    $ gem install igist

## Usage

Before search your gists, authorize and index first:

    $ igist -i

Search by keywords in description

    $ igist -s ruby
    $ igist -s "ruby rails"

For other options

    $ igist -h


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
