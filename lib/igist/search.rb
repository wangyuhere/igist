require "set"

module IGist
  module Search
    def build_index(data)
      index = {}
      data.each { |id, desc| add_to_index(index, id, desc) }
      index.each { |key, value| index[key].uniq! }
      index
    end

    def search_index(index, keyword)
      result = []
      split_words(keyword).each { |p| result.concat(index[p]) if index.has_key?(p)}
      result.uniq
    end

    private

    def add_to_index(index, id, desc)
      split_words(desc).each do |w|
        if index.has_key? w
          index[w] << id
        else
          index[w] = [id]
        end
      end
    end

    def split_words(str)
      str.downcase.split(/\W/).reject { |s| s.empty? }
    end

  end
end