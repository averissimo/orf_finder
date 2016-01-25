require_relative 'orf'

#
#
# Wrapper class that processes the direct and reverse sequences
class ORFFinder
  #
  attr_reader :codon_table
  #
  DEFAULT_OPTIONS = { start: %w(atg),
                      stop:  %w(tag taa tga),
                      reverse: true,
                      direct: true,
                      min: 6,
                      debug: false }

  def initialize(sequence, codon_table = 1, options = {}, logger = nil)
    #
    sequence = Bio::Sequence::NA.new(sequence) if sequence.class == String
    options = DEFAULT_OPTIONS.merge(options.nil? ? {} : options)
    #
    @output = {}
    @output[:direct] = ORF.new(sequence, options, logger) if options[:direct]
    #
    if options[:reverse]
      compl = sequence.complement
      @output[:reverse] = ORF.new(compl, options, logger)
    end
    #
    @codon_table = codon_table
  end

  def nt
    res = {}
    @output.each do |key, value|
      res[key] = value.nt(@codon_table)
      res[key][:sequence] = value.seq
    end
    res
  end

  def aa
    res = {}
    @output.each do |key, value|
      res[key] = value.aa(@codon_table)
      res[key][:sequence] = value.sequence.translate(@codon_table).to_s
    end
    res
  end

  def direct
    @output[:direct]
  end

  def reverse
    @output[:reverse]
  end
end
