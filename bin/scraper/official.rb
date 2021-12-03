#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class Member < Scraped::HTML
  field :name do
    binding.pry if fullname.to_s.empty?
    MemberList::Member::Name.new(
      full:     fullname,
      prefixes: %w[Hon.]
    ).short
  end

  field :position do
    noko.css('h2').map(&:text).map(&:tidy).reject { |txt| txt.include? 'About' }.first
  end

  field :url do
    noko.xpath('//link[@rel="canonical"]/@href').text
  end

  private

  def fullname
    noko.css('.the_content h3').map(&:text).map(&:tidy).reject(&:empty?).first
  end
end

dir = Pathname.new 'mirror'
data = dir.glob('*.html').sort.flat_map do |file|
  request = Scraped::Request.new(url: file, strategies: [LocalFileRequest])
  data = Member.new(response: request.response).to_h
  [data.delete(:position)].flatten.map { |posn| data.merge(position: posn) }
end.uniq

ORDER = %i[name position url].freeze
puts ORDER.to_csv
data.each { |row| puts row.values_at(*ORDER).to_csv }
