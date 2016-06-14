module Parseable

  private

  def next_char
    content[pos]
  end

  def consumed?
    pos >= content.length
  end

  def end_of_content?
    pos >= content.length - 1
  end

  def starts_with?(str)
    content[pos...pos + str.length] == str
  end

  def consume_char
    result = content[pos]
    self.pos += 1
    result
  end

  def consume_while(&prc)
    result = ""
    content[pos..-1].each_char do |char|
      if prc.call(char)
        result << consume_char
      else
        break
      end
    end
    result
  end

  def consume_whitespace
    consume_while do |char|
      char == " " || char == "\n"
    end
  end
end
