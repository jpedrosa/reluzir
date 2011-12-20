#!/usr/bin/env ruby


n = ARGV[0] ? ARGV[0].to_i : 10
a = []
n.times do a << "      '#{rand}':'#{rand}'" end
s = a.join(",\n")


File.open('sample.dart', 'w') do |f| f.puts <<EOS
class ParseDictBench {
  static loadSample() {
    return """{
#{s}
      }""";
  }
}
EOS
end

