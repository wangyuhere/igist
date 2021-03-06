# IGist

[![Gem Version](https://badge.fury.io/rb/igist.png)](http://badge.fury.io/rb/igist)
[![Build Status](https://api.travis-ci.org/wangyuhere/igist.png?branch=master)](https://api.travis-ci.org/wangyuhere/igist.png?branch=master)
[![Code Climate](https://codeclimate.com/github/wangyuhere/igist.png)](https://codeclimate.com/github/wangyuhere/igist.png)
[![Dependency Status](https://gemnasium.com/wangyuhere/igist.png)](https://gemnasium.com/wangyuhere/igist)

IGist is a command line tool used to search your gists and starred gists by keyword of gist description. All your gists will be indexed using simple inversed index algorithm. And the index data is saved locally (~/.igist).

## Installation

    $ gem install igist

Note: ruby 1.9.3+ is required.

## Usage

Before search your gists, authorize and index first:

    $ igist -i

Search by keywords in description

    $ igist -s ruby
    $ igist -s "ruby rails"

Print a single gist by id

    $ igist -p 1

Open a single gist in the browser by gist id

    $ igist -o 1

For other options

    $ igist -h


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
