Gem::Specification.new do |s|
  s.name        = 'orf_finder'
  s.version     = '0.1.2'
  s.date        = '2016-01-25'
  s.summary     = 'Finds the longest orfs in a nucleotide sequence.'
  s.description = <<-EOF
    ORF Finder is a library that with a sequence of nucletotides it
    finds the all the possible ORFs in the sequence.
    It will look for a sequence that starts with a start codon and
    ends with a stop codon.
    It will default to the beggining of the sequence if it cannot
    find an ORF long enought with the start codons. It will also
    use the end of the sequence if no stop codons are present in the
    sequence reading frame.
  EOF
  s.authors     = ['André Veríssimo']
  s.email       = 'andre.verissimo@tecnico.ulisboa.pt'
  s.files       = ['lib/orf_common.rb', 'lib/orf.rb', 'lib/orf_finder.rb']
  s.homepage    = 'http://github.com/averissimo/orf_finder'
  s.license     = 'GPL v3'
  s.add_runtime_dependency 'bio', '~> 1.5', '>= 1.5.0'
  s.add_development_dependency 'byebug', '~> 8.2', '>= 8.2.1'
  s.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
end
