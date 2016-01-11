require 'logger'
#
#
#
module ORFCommon
  #

  def range_to_s(range, str = '')
    print_range(str, range)
  end

  private

  #
  # transform range to sequence
  def get_range(arg1, arg2 = nil)
    return Bio::Sequence::NA.new('') if arg1.nil?
    if arg2.nil?
      start = arg1[:start]
      stop = arg1[:stop]
    else
      start = arg1
      stop = arg2
    end
    Bio::Sequence::NA.new(get_range_str(start, stop))
  end

  #
  # tranform range to string
  def get_range_str(start, stop, include_codons = true)
    # check if there is a start codon before start
    #  and an end codon after stop, if there is, show it!
    start_codon = ''
    stop_codon = ''
    if include_codons
      if start - 3 >= 0 &&
         options[:start].include?(seq[(start - 3)..(start - 1)])
        start_codon = seq[(start - 3)..(start - 1)]
      end

      if stop + 3 <= seq.size - 1 &&
         options[:stop].include?(seq[(stop + 1)..(stop + 3)])
        stop_codon = seq[(stop + 1)..(stop + 3)]
      end
    end
    "#{start_codon}#{seq[start..stop]}#{stop_codon}"
  end

  #
  # auxiliary method that prints range
  def print_range(key, range)
    # simple proc to add spaces, works as auxiliary
    #  method to print range
    add_spaces = proc do |str|
      str.gsub(/([atgc]{1})/, '\1 ').strip
    end
    if range.nil?
      str = "#{key} : (empty)"
    else
      orf = add_spaces.call(get_range_str(range[:start], range[:stop]))
      pre = if range[:start] == 0
              ''
            else
              add_spaces.call(get_range_str(0, range[:start] - 1))
            end
      suf = if range[:end] == seq.size - 1
              ''
            else
              add_spaces.call(get_range_str(range[:stop] + 1, seq.size - 1))
            end
      #
      sep = '|'
      str = "#{key}: #{pre}#{sep}#{orf}#{sep}#{suf}"
      str += ' : ' \
        "size=#{seq[range[:start]..range[:stop]].size}"
      str += ' (fallback)' if range[:fallback]
    end
    puts str
  end

  #
  # necessary normalization for index to start after
  #  start codon and end just before stop codon
  # example: aaa atg aaa aaa taa aaa
  #  the search results in codon 2 and 5, while the
  #  resulting ord are codons 3 and 4
  def index_normalization(option_name, idx)
    if option_name == :start
      idx + 3
    elsif option_name == :stop
      idx - 1
    end
  end

  #
  # create hash symbol from index
  def frame_sym(index)
    "frame#{index + 1}".to_sym
  end

  def size_of_frame(frame)
    seq.size - frame - (seq.size - frame) % 3
  end
end
