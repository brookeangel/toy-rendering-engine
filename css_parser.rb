require 'byebug'
require_relative './parseable.rb'

# h1, h2, h3 { margin: auto; color: #cc0000; }
# div.note { margin-bottom: 20px; padding: 10px; }
# #answer { display: none; }

class StyleSheet
  attr_reader :rules, :content
  attr_accessor :pos

  include Parseable

  def initialize(content)
    @content = content
    @rules = []
    @pos = 0
    parse
  end

  def parse
    consume_whitespace
    until end_of_content?
      consume_whitespace
      @rules << parse_rule
    end
  end

  def to_s
    rules.join("\n")
  end

  private

  def parse_rule
    Rule.new(parse_selectors, parse_declarations)
  end

  def parse_selectors
    selectors = []
    loop do
      selectors << parse_simple_selector
      consume_whitespace
      case
      when next_char == ","
        consume_char
        consume_whitespace
      when next_char == "{"
        break
      when !valid_identifier_char?(next_char)
        raise "Unexpected character in selector list"
      end
    end
    selectors.sort
  end

  def parse_declarations
    raise "invalid declaration" unless consume_char == "{"
    declarations = []

    loop do
      consume_whitespace
      break if end_of_content?
      if next_char == "}"
        consume_char
        break
      else
        declarations << parse_declaration
      end
    end

    declarations
  end

  def parse_declaration
    property_name = parse_identifier
    consume_whitespace
    debugger unless next_char == ":"
    raise "invalid declaration" unless consume_char == ":"
    consume_whitespace
    value = parse_value
    consume_whitespace
    raise "invalid declaration" unless consume_char == ";"

    Declaration.new(property_name, value)
  end

  def parse_value
    consume_while { |char| char != ";" }
  end

  def parse_simple_selector
    selector = SimpleSelector.new
    until end_of_content?
      consume_whitespace
      case
      when next_char == "#"
        consume_char
        selector.ids << parse_identifier
      when next_char == "."
        consume_char
        selector.klasses << parse_identifier
      when next_char == "*"
        consume_char
      when valid_identifier_char?(next_char)
        selector.tag_names << parse_identifier
      else
        break
      end
    end

    selector
  end

  def parse_identifier
    consume_while { |char| valid_identifier_char?(char) }
  end

  def valid_identifier_char?(c)
    !!(c =~ /\w|-/)
  end
end

class Rule
  attr_reader :selectors, :declarations

  def initialize(selectors, declarations)
    @selectors = selectors
    @declarations = declarations
  end

  def to_s
    "Rule #{selectors.join(", ")}: #{declarations.join(", ")}"
  end
end

class SimpleSelector
  attr_accessor :tag_names, :ids, :klasses
  include Comparable

  def initialize(tag_names = [], ids = [], klasses = [])
    @tag_names = tag_names
    @ids = ids
    @klasses = klasses
  end

  def specificity
    [ids.count, klasses.count, tag_names.count]
  end

  def <=>(other_selector)
    ids = specificity[0] <=> other_selector.specificity[0]
    return ids unless ids == 0

    klasses = specificity[1] <=> other_selector.specificity[1]
    return klasses unless klasses == 0

    specificity[2] <=> other_selector.specificity[2]
  end

  def to_s
    str = ""
    str += "Ids: #{ids.join(", ")} " unless ids.empty?
    str += "Classes: #{klasses.join(", ")} " unless klasses.empty?
    str += "Tag Names: #{tag_names.join(", ")}" unless tag_names.empty?
    str
  end
end

class Declaration
  attr_reader :name, :value

  def initialize(name, value)
    @name = name
    @value = value
  end

  def to_s
    "#{name}: #{value}"
  end
end

# styles = StyleSheet.new("
# h1, h2, h3 { margin: auto; color: #cc0000; }
# div.note { margin-bottom: 20px; padding: 10px; }
# #answer { display: none; }
# ")
# puts styles.to_s
