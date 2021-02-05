#!/usr/bin/ruby

#
# Bismillahirrohmanirrohim.
#
# simple script to mutates base word/s to varying mutations,
# it is used to crack password with mutation based.
#
# how to use:
# just input base word/s to $base_words global array variable.
# for every base word, it will create +- 5000 for non-reverse-included
# and +- 8000 for reverse-included basewords.
# so be careful to choose base word, but eventually,
# you can tweak the script as desire.
#
# by faisal and my pal, apin.
# 2021 January.
#


require "pp"
require "chronic"

# just watch this part (these 2 global variable)
$base_words = ["jogja"]
$date = "" # "month date year", empty it as u like.

class String
  def save!(filename)
    File.open(filename, "w") { |f| f.puts(self) }
  end
end

module N0NameCracker
  module Characters
    Az = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
    ZeroNine = %w[0 1 2 3 4 5 6 7 8 9]
    KeyboardSymbols = ['~', '!', '@', '#', '$', '%', '^', '&', 
     '*', '(', ')', '_', '+', '`', '-', 
     '=', '{', '}', ':', '"', '|', '<', '>', 
     '?', '[', ']', ';', "'", "\\", ',', '.', '/']
  end

  def self.mutation_set(mutations, kind=[:end])
    ret = []
    $base_words.each { |base_word|
      mutations.each { |mutation|
        ret << "#{mutation}#{base_word}" if kind.include?(:front)
        ret << "#{base_word}#{mutation}" if kind.include?(:end)
      }
    }
    ret
  end

  def self.auto
    # if the reversed base word can not be spelled or something like that
    # just set this use_reverse variable to false.
    use_reverse = false
    buff = $base_words.collect { |str|
      rvrs = str.reverse.downcase
      [rvrs, rvrs.capitalize, rvrs.upcase ]
    }.flatten
    $base_words = Az.n4
    $base_words = ($base_words + buff) if use_reverse

    ret = []
    [Az, ZeroNine, AzZeroNine, KeyboardSymbols, Miscs].each { |e|
      (1..10).each { |n|
        begin
          ret << e.send("n#{n}")
        rescue NoMethodError
        end
      }
    }
    return ret.flatten.uniq
  end

  module Az
    class << self
    # ref: 2
    def n1
      ret = []
      $base_words.each { |base_word|
        last_character = base_word[-1]
        (1..4).each { |n|
          ret << "#{base_word}#{last_character*n}"
        }
      }
      return ret
    end

    # ref: 6
    def n2
      ret = []
      $base_words.each { |base_word|
        ret << (base_word*2)
      }
      return ret
    end

    # ref: 7
    def n3
      return N0NameCracker.mutation_set(%w[aaa bbb ccc ddd eee 
        fff abc def ghi jkl xyz abcdef wxyz])
    end

    # ref: 8
    def n4
      ret = []
      blk = Proc.new do |str|
        str = str.downcase
        s1 = ""
        s2 = ""
        str.each_char.each_with_index do |c, i|
          s1 << ( i.even? ? c.upcase : c )
          s2 << ( i.odd? ? c.upcase : c )
        end
        [s1, s2]
      end
      $base_words.each do |base_word|
        base_word = "".replace(base_word).downcase
        ret << base_word << base_word.capitalize << base_word.upcase
        ret << blk.call(base_word)
      end
      return ret.flatten
    end

    def n5
      return N0NameCracker.mutation_set(%w[qwerty qwertyuiop zxcvbnm 
        asdfgh pass fuck aaaaaa love qwerty123 asdfghjkl])
    end

    end
  end # end of module Az

  module ZeroNine
    class << self

    # ref: 1
    def n1
      return N0NameCracker.mutation_set(
      %w[ 123 1234 12345 123456 1234567 
      12345678 123456789 1234567890 111111 999999
      123123 696969 666666 123321 654321 121212 
      000000 2000 112233 1111 555555 11111111 131313
      777777 159753 6969 987654321 27653 987 321 ],
      [:front, :end])
    end

    # ref: 3
    def n2
      # $date must be a format of: "month date year"
      return [] if $date.nil? or $date.empty?
      mutations = []
      t = Chronic.parse($date)
      day = ( "%02d" % t.day )
      month = ( "%02d" % t.month )
      first_half_year = t.year.to_s[0..1]
      second_half_year = t.year.to_s[2..3]
      mutations << "#{day+month+t.year.to_s}" << "#{t.year.to_s+month+day}" <<
        "#{day+month+second_half_year}" << "#{second_half_year+month+day}" <<
        t.year.to_s << second_half_year << second_half_year+first_half_year
      return N0NameCracker.mutation_set(mutations, [:front, :end])
    end

    # ref: 5
    def n3
      return N0NameCracker.mutation_set(
        (1..6).to_a.collect { |n| 
          N0NameCracker::Characters::ZeroNine.collect { |e|
            e * n
          }
        }.flatten,
        [:end]
      )
    end

    # ref: metasploit: prepending single digit
    def n4
      ret = []
      $base_words.each { |base_word|
        (0..9).each { |n|
          ret << "#{n}#{base_word}"
        }
      }
      return ret
    end

    # ref: metasploit: prepending & appending years
    def n5
      return N0NameCracker.mutation_set(
        (1995..2025).to_a.collect { |year|
          year = year.to_s
          [year, year[0..1], year[2..3], (year[2..3]+year[0..1])]
        }.flatten, [:front, :end]
      )
    end

    # ref: metasploit: appending & prepending digit(S)
    def n6
      return [] # shorter time for cracking
      return N0NameCracker.mutation_set(
        (0..999).to_a.collect { |n|
          "%03d" % n
        },
        [:front, :end]
      )
    end

    end
  end # end of module ZeroNine

  module AzZeroNine
    class << self

    # ref: 4 (leetspeak)
    def n1
      ret = []
      leetspeak = {
        '@' => 'a',
        '4' => 'a',
        '3' => 'e',
        '1' => 'l',
        '0' => 'o',
        '5' => 's',
        '$' => 's',
        '7' => 't'
      }

      $base_words.each do |str|
        leetspeak.each do |k,v|
          (0...str.size).each {|n|
            if str[n] == v
              str_c = "".replace(str)
              str_c[n] = k
              ret << str_c
            end
          }
        end

        str_c = "".replace(str)
        leetspeak.each do |k,v|
          str_c.gsub!(v, k)
        end
        ret << str_c
        ret << str_c.gsub('@', '4') if str_c.include?('@')
        ret << str_c.gsub('5', '$') if str_c.include?('5')
      end
      return ret
    end

    # ref: 9
    def n2
      return AzZeroNine.n1.collect { |e|
        %w[123 12 987 321 00 0 000].collect { |n|
          [(e+n), (n+e)]
        }
      }.flatten
    end

    end
  end # end of module AzZeroNine

  module KeyboardSymbols
    class << self

    # ref: 10 (delimiter)
    def n1
      delimiters = %w[. - ~ ^ * _ + , /]
      ret = []
      $base_words.each do |base_word|
        delimiters.each do |delimiter|
          ret << base_word.split("").join(delimiter)
        end
      end
      return ret
    end

    # ref: 11 & 15
    def n2
      return N0NameCracker.mutation_set(
        N0NameCracker::Characters::KeyboardSymbols.collect { |symbol|
          [symbol, symbol*2]
        }.flatten,
        [:end, :front]
      )
    end

    # ref: 12 & 16
    def n3
      # return []
      base_words = $base_words
      $base_words = Az.n1
      ret = KeyboardSymbols.n2
      $base_words = base_words
      return ret
    end

    # ref: 13
    def n4
      return $base_words.collect { |base_word|
        ["#{base_word}___", "___#{base_word}___", "___#{base_word}"]
      }.flatten
    end

    # ref: 17 (tags)
    def n5
      ret = []
      [%w[< >], %w[( )], %w[{ }], %w[[ ]], %w[" "], %w[' ']].each { |e|
        $base_words.each { |str|
          ret << "#{e.at(0)}#{str}#{e.at(1)}"
        }
      }
      return ret
    end

    # ref: 20
    def n6
      return $base_words.collect { |base_word|
        "#{base_word}.#{base_word}"
      }
    end

    end
  end # end of module KeyboardSymbols

  module Miscs
    # ref: 14
    def self.n1
      mut = ['^-^', ';;)', '>:D<', ':-/', ':-*', '(-.-)', ':((', '=((', ':-s',
      '>:)', ':))', '=))', ':@)', ':( | )', '~:>', '@};--', ':-?', '=D>', ':D>', '[-o<',
      ';))', 'O:)', 'O:-)', ':-<>', ':)', ':-)', ':>', ':->', '=)', '=]', '=>', ':D', ':-D',
      '=D', ';)', ';-)', ';}', ';-]', ';D', ';-D', ':|', ':-|', '=|', ':(', ':-(', ':<', ':-<',
      ':[', '=(', '=[', '^-^', ':P', '=P', ':*', '=*', ':X', '=x', ':O', '=O', ':s', '=S', '>:<',
      '(-.-) zzZ', ':=o', ':B', '>->', '*<):o)', '< - |', '&:-)', '|-)', '*W*', '>-',
      ':-ozz', '>:-!', 'O:)']
      return N0NameCracker.mutation_set(mut, [:end])
    end
  end
end

password_mutations = N0NameCracker.auto
puts "Size: #{password_mutations.size}"
password_mutations.join("\n").save!("mutations.txt")
