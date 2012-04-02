#! /usr/bin/ruby1.9
# -*- coding: utf-8 -*-
require 'optparse'
require 'diff/lcs'

class String
  def normalize!
    self.tr! "１-９", "1-9"
    self.tr! "Ａ-Ｚａ-ｚ", "A-Za-z"
    self.tr! "！″＃＄％＆（）＊＋，．／：；＜＝＞？＠［＼］＾＿｛｜｝", "!\"\#$%&()*+,./:;<=>?@[\\]^_{|}"
  end
end

class Callback
  @old_elements
  @new_elements
  @verbose
  attr_accessor :n_lcs
  def initialize(verbose)
    @old_elements = []
    @new_elements = []
    @n_lcs = 0;
    @verbose = verbose
  end
  def print s
    Kernel.print s if @verbose
  end
  def flash
    if @old_elements.size > 0 or @new_elements.size > 0
      print "[#{@old_elements.join}|#{@new_elements.join}]"
      @old_elements = []
      @new_elements = []
    end
  end
  def match a
    flash
    @n_lcs += 1
    print a.old_element
  end
  def discard_a evt
    @old_elements.push evt.old_element
  end
  def discard_b evt
    @new_elements.push evt.new_element
  end
  def finish
    flash
    print "\n"
  end
end

verbose = false
opt = OptionParser.new
opt.on('-v', '--verbose') {|v| verbose = v }
opt.parse!(ARGV)

fail "Too few arguments" if ARGV.size < 2

f1 = open ARGV[0]
f2 = open ARGV[1]

n_chars1 = 0
n_chars2 = 0
n_lcs = 0

while true
  line1 = f1.gets
  line2 = f2.gets
  break if !line1 or !line2
  line1.chomp!
  line2.chomp!
  line1.normalize!
  line2.normalize!
  seq1 = line1.split(//)
  seq2 = line2.split(//)

  cb = Callback.new(verbose)
  Diff::LCS.traverse_sequences(seq1, seq2, cb)
  cb.finish
  
  n_chars1 += seq1.size;
  n_chars2 += seq2.size;
  n_lcs += cb.n_lcs
end

puts "n_chars1: #{n_chars1}"
puts "n_chars2: #{n_chars2}"
puts "n_lcs: #{n_lcs}"
puts "2 * n_lcs / (n_chars1 + n_chars2): #{2.0 * n_lcs / (n_chars1 + n_chars2)}"
puts "n_lcs / n_chars1: #{n_lcs.to_f / n_chars1}"
puts "n_lcs / n_chars2: #{n_lcs.to_f / n_chars2}"
