#!/usr/bin/env ruby

def linux?
  RUBY_PLATFORM.include?("linux")
end

def macos?
  RUBY_PLATFORM.include?("darwin")
end

def run(cmd)
  `#{cmd} 2>/dev/null`
end

def which(cmd)
  system("which #{cmd} > /dev/null 2>&1")
end

def parse_lsof
  output = run("lsof -nP -iTCP -sTCP:LISTEN -iUDP")
  rows = []
  output.each_line.with_index do |line, i|
    next if i.zero? # header
    fields = line.split(/\s+/)
    next if fields.size < 9

    command = fields[0]
    pid     = fields[1]
    name    = fields[8] 
    proto   = fields[7] # TCP or UDP

    addr_port, state = name.split(/\s+/, 2)
    next unless addr_port

    if addr_port =~ /^(.*):(\d+|\*)$/
      addr = $1
      port = $2
      state ||= (proto == "TCP" ? "LISTEN" : "-")
      rows << [proto, addr, port, "#{command}(#{pid})", state.gsub(/[()]/, "")]
    end
  end
  rows
end

def parse_ss
  output = run("ss -tulpn")
  rows = []
  output.each_line.with_index do |line, i|
    next if i.zero?
    fields = line.split(/\s+/)
    next if fields.size < 5

    proto        = fields[0].upcase
    state        = fields[1]
    local_addr_port = fields[4]
    process_info = fields[-1]

    next unless local_addr_port =~ /^(.*):(\d+|\*)$/
    addr = $1
    port = $2

    proc_name = if process_info =~ /users:\(\("([^"]+)",pid=(\d+)/
                  "#{$1}(#{$2})"
                else
                  "-"
                end

    rows << [proto, addr, port, proc_name, state]
  end
  rows
end

def parse_netstat_fallback
  output = run("netstat -anp tcp 2>/dev/null; netstat -anp udp 2>/dev/null")
  rows = []
  output.each_line do |line|
    next unless line =~ /^(tcp|udp)/i
    fields = line.split(/\s+/)
    next if fields.size < 4

    proto = fields[0].upcase
    local = fields[3]
    state = fields[5] || "-"

    next unless local =~ /[.:](\d+)$/
    port = $1
    addr = local.sub(/[.:]#{port}$/, "")

    rows << [proto, addr, port, "-", state]
  end
  rows
end

rows =
  if which("lsof")
    parse_lsof
  elsif which("ss")
    parse_ss
  else
    parse_netstat_fallback
  end

if rows.empty?
  puts "No open ports found, or insufficient permissions."
  puts "Try running with sudo for full process details."
  exit 0
end

rows.uniq!
rows.sort_by! { |r| r[2].to_i }

proto_w = rows.map { |r| r[0].length }.max
addr_w  = rows.map { |r| r[1].length }.max
port_w  = rows.map { |r| r[2].length }.max
proc_w  = rows.map { |r| r[3].length }.max

header = format(
  "%-#{proto_w}s  %-#{addr_w}s  %-#{port_w}s  %-#{proc_w}s  %s",
  "PROTO", "ADDRESS", "PORT", "PROCESS", "STATE"
)
puts header
puts "-" * header.length

rows.each do |proto, addr, port, proc_name, state|
  puts format(
    "%-#{proto_w}s  %-#{addr_w}s  %-#{port_w}s  %-#{proc_w}s  %s",
    proto, addr, port, proc_name, state
  )
end

puts
puts "Total: #{rows.size} open port(s)"