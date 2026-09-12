#!/usr/bin/env ruby

VERSION_NAMES = {
  27 => "Golden Gate",
  26 => "Tahoe",
  15 => "Sequoia",
  14 => "Sonoma",
  13 => "Ventura",
  12 => "Monterey",
  11 => "Big Sur",
  "10.15" => "Catalina",
  "10.14" => "Mojave",
  "10.13" => "High Sierra",
  "10.12" => "Sierra",
  "10.11" => "El Capitan",
  "10.10" => "Yosemite",
  "10.9"  => "Mavericks",
  "10.8"  => "Mountain Lion",
  "10.7"  => "Lion",
  "10.6"  => "Snow Leopard",
  "10.5"  => "Leopard",
  "10.4"  => "Tiger",
  "10.3"  => "Panther",
  "10.2"  => "Jaguar",
  "10.1"  => "Puma",
  "10.0"  => "Cheetah"
}.freeze

def macos_version
  `sw_vers -productVersion`.strip
end

def version_name(version)
  major, minor = version.split(".").first(2).map(&:to_i)

  if major >= 11
    VERSION_NAMES[major] || "Unknown"
  else
    VERSION_NAMES["#{major}.#{minor}"] || "Unknown"
  end
end

unless RUBY_PLATFORM.include?("darwin")
  warn "This script only works on macOS."
  exit 1
end

version = macos_version
name = version_name(version)

puts "macOS Version: #{version}"
puts "Version Name:  #{name}"