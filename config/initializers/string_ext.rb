class String
  def bin_to_hex
    unpack("H#{bytesize*2}").first
  end

  def hex_to_bin
    [self].pack("H#{bytesize}")
  end
end
