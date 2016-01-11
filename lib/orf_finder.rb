require_relative 'orf'

#
#
# Wrapper class that processes the direct and reverse sequences
class ORFFinder
  #
  DEFAULT_OPTIONS = { start: %w(atg),
                      stop:  %w(tag taa tga),
                      reverse: true,
                      direct: true,
                      min: 6,
                      default_to_seq: false,
                      debug: false }

  def initialize(sequence, options = {}, logger = nil)
    #
    sequence = Bio::Sequence::NA.new(sequence) if sequence.class == String
    options = DEFAULT_OPTIONS.merge(options.nil? ? {} : options)
    #
    @output = {}
    @output[:direct]  = ORF.new(sequence, options, logger) if options[:direct]
    @output[:reverse] = ORF.new(sequence.complement, options, logger) \
      if options[:reverse]
  end

  def nt
    res = {}
    @output.each do |key, value|
      res[key] = value.nt
    end
    res
  end

  def aa
    res = {}
    @output.each do |key, value|
      res[key] = value.aa
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
