require 'bio'

require_relative 'orf_common'
require_relative 'orf_finder'
#
#
#
class ORF
  #
  include ORF::ORFCommon
  #
  DEFAULT_CODON_TABLE = 1
  #
  attr_reader :logger, :options, :seq, :sequence, :codon_table
  attr_writer :options
  #
  # class initializer that normalizes sequence to Bio::Sequence,
  #  merges given options and creates logger
  def initialize(sequence, options = {}, logger_file = nil)
    # logger for instance
    if logger_file.nil?
      @logger = Logger.new(STDOUT)
    else
      @logger = logger_file.clone
    end
    logger.progname = 'ORFCommon'
    logger.level    = (options[:debug] ? Logger::INFO : Logger::ERROR)
    #
    sequence = Bio::Sequence::NA.new(sequence) if sequence.class == String
    @sequence = sequence
    @seq = @sequence.to_s
    #
    self.options = ORFFinder::DEFAULT_OPTIONS.merge(options.nil? ? {} : options)

    logger.info 'ORF has been initialized'
    find
  end

  #
  # For a given sequence, find longest ORF
  #
  def self.find(sequence, options = {})
    # merge options with default
    orf = ORF.new(sequence, options)
    @result = orf.find
    #
  end

  #
  # return aminoacid sequence
  def aa(codon_table = DEFAULT_CODON_TABLE)
    # return already generated aa sequence
    return @res_aa unless @res_aa.nil?
    # save result
    l = longest(codon_table)
    return l if @res_aa.nil?
    @res_aa
  end

  #
  # return nucletotide sequence
  def nt(codon_table = DEFAULT_CODON_TABLE)
    return @res_nt unless @res_nt.nil?
    longest(codon_table)
  end

  #
  #
  # finds all possible orfs in sequence
  def find
    # if sequence is nil or empty there is no point
    #  in trying to run the find algorithm
    return sequence if sequence.nil? || sequence.size == 0
    #
    orf = { frame1: {}, frame2: {}, frame3: {} }
    #
    start_idx = all_codons_indices(:start)
    stop_idx  = all_codons_indices(:stop)
    res       = all_sequences(start_idx, stop_idx, seq.size, [0, 1, 2])
    #
    logger.info "start codons idx: #{start_idx}"
    logger.info "stop codons idx: #{stop_idx}"
    logger.info res
    # iterate over each frame and range to return the
    #  longest above the minimum sequence length
    # these are the preferences:
    #  1: range that has start and stop codons
    #  2: range that only has start/stop
    #  3: full sequence
    res.each_with_index do |frame, index|
      find_longest(frame, index, orf)
    end
    # print ranges if debug is activated
    orf.each { |k, f| f[:orfs].each { |r| print_range(k, r) } } \
      if options[:debug]
    #
    @orf = orf
  end

  private

  #
  # iterate over all ranges in frame and find the longest
  def find_longest(frame, index, orf)
    # temporary arrays to keep valid and fallback ranges
    frame_val = []
    frame_fal = []
    frame.each do |range|
      if range[:fallback]
        frame_fal << range
      else
        frame_val << range
      end
    end
    # hash name
    hash_name = frame_sym(index)
    orf[hash_name][:orfs] = (frame_val.empty? ? frame_fal : frame_val)
    longest = { len: nil, range: nil }
    orf[hash_name][:orfs].each do |range|
      len = range[:stop] - range[:start] + 1
      if longest[:range].nil? || len > longest[:len]
        longest[:len]   = len
        longest[:range] = range
      end
    end
    orf[hash_name][:longest] = longest[:range]
  end

  #
  # get the longest sequence in each frame and translate
  #  to aminoacid
  def longest(codon_table = DEFAULT_CODON_TABLE)
    # run find method if search has not been done
    find if @orf.nil?
    #
    res_nt = { frame1: '', frame2: '', frame3: '' }
    res_aa = res_nt.clone
    # if @orf is empty then no point in continuing
    return res_nt if @orf.nil? || @orf.size == 0
    # for each orf get the longest sequence
    @orf.each do |key, val|
      res_nt[key] = get_range(val[:longest])
    end
    @res_nt = res_nt
    # translate to aa sequence
    unless @res_nt.nil?
      @res_nt.each do |key, val|
        res_aa[key] = if val.nil? || val.empty?
                        ''
                      else
                        val.translate(1, codon_table)
                      end
      end
    end
    @res_aa = res_aa
    # return the nucleotide sequence as default
    res_nt
  end

  #
  # Find all indexes for valid codons
  #  (either for :start or :stop)
  def all_codons_indices(option_name)
    idxs = []
    option_name = option_name.to_sym
    # if start option does not exist, then should
    #  treat start of sequence as the start
    return idxs if options[option_name].nil? || options[option_name].empty?
    # iterate over all start codons to see which
    #  is best
    options[option_name].each do |codon|
      # initialize temporary index as empty
      temp_idxs = []
      # index starts at position 0
      new_idx   = seq.index(codon, 0)
      until new_idx.nil?
        # necessary normalization
        temp_idxs << index_normalization(option_name, new_idx)
        new_idx   = seq.index(codon, new_idx + 1)
      end
      idxs << temp_idxs
    end
    idxs.flatten.sort
  end

  #
  # get indexes only from a given frame
  # because of a bug the start flag must be given
  #  indicating if it is looking for start or stop
  #  codons in frame
  def filter_codons_by_frame(idxs, frame, start = true)
    idxs.collect do |i|
      if start && (i - frame) % 3 == 0
        i
      elsif !start && (i + 1 - frame) % 3 == 0
        i
      end
    end.compact
  end

  #
  # from the combination of start and stop indexes, find
  #  the longest one
  def valid_sequences_by_frame(start_idxs, stop_idxs, frame, seq_size)
    #
    seq_size -= (seq_size - frame) % 3
    start = start_idxs.clone
    stop  = stop_idxs.clone
    #
    stop << seq_size - 1 if stop_idxs.empty?
    start << frame if start_idxs.empty?
    #
    if options[:debug]
      logger.info "frame: #{frame}"
      logger.info "  start: #{start} | stop :#{stop}"
      logger.info "  seq size: #{seq_size}"
      logger.info "  #{seq[frame..seq_size]}"
    end
    #
    valid = []
    fallback = []
    # iterate on each start codon
    sequences_in_frame({ start: start, stop: stop },
                       { valid: valid, fallback: fallback },
                       seq_size,
                       frame,
                       start_idxs.empty? || stop_idxs.empty?)
    if valid.empty?
      valid = fallback.uniq.collect do |r|
        if get_range_str(r[:start],
                         r[:stop],
                         false).size == size_of_frame(frame)
          nil
        else
          r
        end
      end.compact
      logger.info 'no ORF with start and stop codons,' \
        ' defaulting to fallback'
    end
    valid
  end

  #
  # given star and stop codons indexes, decide which are the valid
  #  sequence for an orf
  # TODO: reject sequences that have a stop codon in them
  def sequences_in_frame(idxs, arrays, seq_size, frame, added_pos)
    start = idxs[:start]
    stop  = idxs[:stop]
    arr   = []
    #
    #
    # iterate on each start codon
    start.each do |pos_start|
      # iterate on each stop codon
      stop.each do |pos_stop|
        # add a fallback where starts from begining
        # note: must check if from beggining to end there
        #  are stop codons, if so do not show it
        if (pos_stop + 1 - frame) >= options[:min] &&
           !(pos_stop > stop.bsearch { |el| el >= (frame - 1) })
          arr << { start: frame, stop: pos_stop, fallback: true }
        end
        # ignore if start is bigger than stop index
        next if pos_start >= pos_stop
        # ignore if there is a stop codon between pos_start
        #  and pos_stop
        next if pos_stop > stop.bsearch { |el| el >= (pos_start - 1) }
        # ignore if size of orf is smaller than minimum
        next if (pos_stop + 1 - pos_start) < options[:min]
        # if all conditions hold add as valid orf
        arr << { start: pos_start,
                 stop:  pos_stop,
                 fallback: added_pos }
      end
      next unless ((seq_size - 1) - pos_start) >= options[:min]

      next if !(temp_res = stop.bsearch { |el| el >= (pos_start - 1) }).nil? &&
              (seq_size - 1) > temp_res
      arr << { start: pos_start,
               stop: seq_size - 1,
               fallback: true }
    end
    #
    arr.each do |item|
      if item[:fallback]
        arrays[:fallback] << item
      else
        arrays[:valid] << item
      end
    end
  end

  #
  #
  #
  def all_sequences(start_idx, stop_idx, seq_size, read_frame = [0, 1, 2])
    #
    start = [[], [], []]
    stop  = [[], [], []]
    valid = []
    read_frame.each do |frame|
      start[frame] = filter_codons_by_frame(start_idx, frame, true)
      stop[frame]  = filter_codons_by_frame(stop_idx, frame,  false)
      valid << valid_sequences_by_frame(start[frame],
                                        stop[frame],
                                        frame, seq_size)
    end
    #
    valid
  end
end
