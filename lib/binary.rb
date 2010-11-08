
module Binary
  def self.string2binary(string)
    base = 2
    bits_per_char = 8
    string.each_byte.map { |b| sprintf("%0#{bits_per_char}d", b.to_s(base)) }.join('')
  end

  def self.binary2string(string)
    base = 2
    bits_per_char = 8
    unless string.length % bits_per_char == 0
      raise "string length must be a multiple of #{bits_per_char}"
    end

    chars = string.chars.each_slice(bits_per_char).map do |slice|
      byte = slice.join('').to_i(base)
      byte.chr
    end
    chars.join('')
  end
end
