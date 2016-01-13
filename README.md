# ORF-Finder

**Website**: [http://sels.tecnico.pt/orf_finder](http://sels.tecnico.pt/orf_finder/)

ORF-Finder is a library that finds the longest Open Reading Frame (ORF) from a nucleotide sequence.

It will search the sequence for existing start and stop codons and return a single ORF for each frame.

When there is not a ORF present with any of the configurated start and stop codons, then it fallbacks to:
 - Using the first codon of the sequence when:
   - No start codon is present;
   - The lenght of an ORF is shorter than the minimum option;
 - Using the last codon of the sequence when:
   - No stop codon is present.

note: this was developed in parallell with [mass-blast](http://github.com/averissimo/mass-blast) and due to the lack of a Ruby library that had this functionality.

# Installation

ORF-Finder can be installed from RubyGems.org by:

    gem install orf_finder

or adding to the [Gemfile](http://bundler.io/gemfile.html):

    gem 'orf_finder'

or adding directly from the github repository:

    gem 'orf_finder', github: 'averissimo/orf_finder'

# Usage

There are two classes that can be used to search for ORF,
  - ORFinder: can look at both the direct sequence or the complement.

        my_orf = ORFFinder.new('aaaatgaaaaaaatgtaaaaa', min: 3)
        my_orf.nt # returns the longests ORFs for all reading frames as a nucleotide sequence, both the direct and complement
        my_orf.nt # returns the longests ORFs for all reading frames as an amino-acid sequence, both the direct and complement


  - ORF: only looks at the direct string.

        my_orf = ORF.new('aaaatgaaaaaaatgtaaaaa', min: 3)
        my_orf.nt # returns the longests ORFs for all reading frames as a nucleotide sequence, both the direct and complement
        my_orf.nt # returns the longests ORFs for all reading frames as an amino-acid sequence, both the direct and complement


# Options

- 'start': list of strings
  - Defines the allowed start codons
- 'stop': list of strings
  - Defines the allowed stop codons
- 'reverse': true/false
  - Whether it should look at the complement
- 'direct': true/false
  - Whether it should look at the direct sequence (as is)
- 'min': integer
  - Minimum length for an ORF to be considered
- 'debug': true/false
  - Whether or not to create an log file

# Ackowledgements

  This tool was created as a part of [FCT](www.fct.p) grant SFRH/BD/97415/2013 and European Commission research project [BacHBerry](www.bachberry.eu) (FP7- 613793)

  [Developer](http://web.tecnico.ulisboa.pt/andre.verissimo/)
