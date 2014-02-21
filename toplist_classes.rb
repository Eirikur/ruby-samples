module Toplist_Classes

# Classes that implement the data structures for a daytrading alerts application which looks for trends and
# 'Velocity;' the rate that money is pouring into or out of a security.  It's from 2000.
# The most interesting things to me, upon reexamination, are the definition of a to_s function for a class
# and the overriding of << to allow appending an object of one type to an object of another.  This made
# the main line code more readable.

class Quote
attr_reader :symbol, :volume, :price, :time, :open_orders, :net_change, :percent_change, :rank
  def initialize(symbol, volume, price, time, open_orders, net_change, percent_change, rank)
    @symbol = symbol
    @volume = volume
    @price = price
    @time = time
    @open_orders = open_orders
    @net_change = net_change
    @percent_change = percent_change
    @rank = rank
  end

  def to_s
    "Volume: #{@volume}, Price: #{@price}, Time: #{@time}, Percent #{@percent_change}"
  end # def to_s

end # class Quote

#myQuote = Quote.new(123456,199.99,"12:30",666,1.98,40,22)


class Ticker
  include Enumerable
  attr_reader :velocity, :quotes, :symb, :up, :down, :rank

  def initialize(symb)
    @velocity = 0
    @symb = symb
    @quotes = []
    @up = 0
    @down = 0
    @rank = 0
    self
  end

  def << (theQuote)
    if @quotes.size != 0 # if this is not the first entry
      if @quotes.last.time != theQuote.time # if the timestamp is new
	delta_minutes = (theQuote.time - self.quotes.first.time) / 60
	delta_dollars = ((theQuote.price - self.quotes.first.price)*100).floor.to_f/100
	@velocity =  (delta_dollars / delta_minutes)
      end # new timestamp
      @up += 1 if @quotes.last.rank > theQuote.rank
      @down += 1 if @quotes.last.rank < theQuote.rank
      # just for now... debugging, monitoring.
#      if @quotes.last.rank != theQuote.rank
#	puts "#{@symb} #{@quotes.last.rank} -> #{theQuote.rank} Up: #{@up} Down: #{@down} %: #{theQuote.percent_change}"
#      end # if rank not equal
    end # this is not the first entry
    @quotes << theQuote
    @rank = theQuote.rank
  end  # <<




def lister # Just for debugging
  puts self
  self.quotes.each { |aQuote| puts aQuote.to_s }
end


def to_s
  "#{symb}" # just return the symbol
end # to_s


def size
  @quotes.length # Our size is our number
end

end # Class Ticker



class TickerList
attr_reader :symbol_list
  def initialize(file_name)
    @file_name = file_name
    @symbol_list = []
    self
  end


  def addQuote(theQuote) # append quote to old or new symbol object
    @symbol_list.each do |this|
      if this.symb == theQuote.symbol
	this << theQuote
	return
	end
    end

    puts "New: #{theQuote.symbol}"
    @symbol_list << Ticker.new(theQuote.symbol)
    @symbol_list.last << theQuote
  end

  def save
    File.open(@file_name, "w+") { |f| Marshal.dump(@symbol_list,f) }
  end



  def restore
#    begin
    @symbol_list = []
    File.open(@file_name) do |f|
      @symbol_list = Marshal.load(f)
    end
  rescue SystemCallError
    puts "No database found, initializing..."
#  else
#    puts "Database loaded."
  end # TickerList.restore

  def lister
    @symbol_list.each { |theSymb| theSymb.lister }
  end

  def symbols
    temp_array = []
    @symbol_list.each { |theSymb| temp_array << theSymb }
    temp_array # return the array
  end


  def each
    @symbol_list.each {|x| yield x} # This should yield each object
  end

  def size
    @symbol_list.length
  end

end # class TickerList


# a Trend is an unbroken sequence of motion in a direction.
class Trend
  attr_reader :symbol, :value, :direction, :delta_time, :delta_price
  def initialize(symbol, delta_time, delta_price)
    @symbol = symbol
    @value = value
    @direction = direction # +1 or -1, only
    @delta_price = delta_price
    @delta_time = delta_time
    @quotes = []
  end

def continue(theQuote)
#if theQuote.price - @quotes.last.price <= 0
end


end # class Trend




end # Module Toplist_Classes
