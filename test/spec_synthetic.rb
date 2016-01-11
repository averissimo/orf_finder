require_relative 'spec_helper'
require 'logger'

#
#
RSpec.describe ORF do
  describe '#nt' do
    #
    parent = File.expand_path(File.join('test', 'find_orfs'))
    # file that contains all tests

    context 'synthetic test input' do
      test_against_file 'synthetic.yml', parent
    end
  end
end
