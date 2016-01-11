require_relative '../lib/orf'

require 'yaml'
require 'rspec'

#
def test_against_file(test_file, parent)
  YAML.load_file(File.join(parent, test_file))['test']
    .each_with_index do |item, index|
    #
    it "hashes shoud match in test \##{index}" do
      orf = ORF.new(item['input'], symbolize_keys(item['config']),
                    Logger.new('log.test.orf.txt'))
      orf.find
      expect(orf.nt).to eq(symbolize_keys(item['output']))
    end
  end
end

def symbolize_keys(old_hash)
  new_hash = {}
  old_hash.keys.each do |key|
    new_hash[key.to_sym] = old_hash[key]
  end
  new_hash
end
