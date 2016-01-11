require_relative '../lib/orf'

require 'yaml'
require 'rspec'

#
def test_against_file(test_file, parent)
  YAML.load_file(File.join(parent, test_file))[:test]
    .each_with_index do |item, index|
    #
    it "hashes shoud match in test \##{index}" do
      orf = ORF.new(item[:input], item[:config], Logger.new('log.test.orf.txt'))
      orf.find
      expect(orf.nt).to eq(item[:output])
    end
  end
end
