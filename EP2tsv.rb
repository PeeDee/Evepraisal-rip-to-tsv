#!/usr/local/bin/ruby
# EP2tsv.rb

# script to strip prices from an Evepraisal page into tab separated text
# usage: ruby EP2tsv.rb http://evepraisal.com/estimate/1214724 > 1214724.tsv

# developed on ruby 1.9.3p374
require 'open-uri' # to treat web urls as files
require 'nokogiri' # nokogiri (1.5.6) for html parsing
# require 'pry'     # pry (0.9.11.4) for live interaction and debugging

TEST_URL = "http://evepraisal.com/estimate/1214724"

class Evepraisal_result_page

  def initialize(url)
    $stderr.puts "Evepraisal_result_page: Initialising file...\n"
    if (@doc = Nokogiri::HTML(open(url))).nil?
      raise IOError, "Evepraisal_result_page: Unable to open url '#{url}'."
    end
    result_rows = @doc.at("#results").at("tbody").search("tr.line-item-row")
    #result_rows.last.pry
    @result_list = []
    result_rows.each { |r| @result_list << EP_result.new(r) }
    return self
  end

  def to_tsv
    tsv_str = ""
    @result_list.each { |r| tsv_str << "#{r.to_tsv}\n" }
    tsv_str
  end

end

class EP_result

  def initialize(nk_object)
    nk = nk_object; cells = nk.search("td")
    @qty = cells[0].child.inner_text
    @name = cells[1].search("a")[1].text
    @size = cells[2].text # "[100.00m3]" or [10 * 100.00m3] need to remove brackets and m3
    @sell = cells[3].search("span").first.text
    @buy = cells[3].search("span").last.text
    @total_sell = cells[4].search("span").first.text
    @total_buy = cells[4].search("span").last.text
    #puts @name
    return self
  end

  def to_tsv
    "#{@name}\t#{@buy}\t#{@sell}\t#{@qty}\t#{@size}\t#{@total_buy}\t#{@total_sell}"
  end

end


## COMMAND LINE

if $0 == __FILE__
  $stderr.sync = $stdout.sync = true # so output is synchronised
  url = TEST_URL unless url = ARGV[0]
  raise IOError, "Unable to read Evepraisal page." unless ep = Evepraisal_result_page.new(url)
  puts ep.to_tsv
end
