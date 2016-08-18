require 'byebug'
require_relative './node.rb'
require_relative './parseable.rb'

# Allowed:
# Balanced tags
# Attributes with quoted values
# Text nodes

class HTMLParser
  attr_reader :content
  attr_accessor :pos

  include Parseable

  def initialize(content)
    @content = content
    @pos = 0
  end

  def parse
    nodes = parse_nodes

    if nodes.length == 1
      nodes.first
    else
      Element.new("html", nodes, {})
    end
  end

  private

  def parse_element
    raise "invalid open tag" unless consume_char == "<"

    tag_name = parse_tag_name
    attrs = parse_attrs

    raise "invalid open tag" unless consume_char == ">"

    children = parse_nodes

    check_close_tag(tag_name)

    Element.new(tag_name, children, attrs)
  end

  def check_close_tag(tag_name)
    unless consume_char == "<" && consume_char == "/" && parse_tag_name == tag_name && consume_char == ">"
      raise "invalid close tag"
    end
  end

  def parse_stylesheet
    stylesheet = consume_while { |char| !starts_with?("</") }
    StyleSheet.new(stylesheet)
  end

  def parse_nodes
    nodes = []

    while !(starts_with?("</") || end_of_content?)
      consume_whitespace
      return nodes if starts_with?("</")
      nodes.push(parse_node)
    end

    nodes
  end

  def parse_attrs
    attrs = {}

    loop do
      consume_whitespace
      break if next_char == ">"
      key, val = parse_attr
      attrs[key] = val
    end

    attrs
  end

  def parse_attr
    name = parse_tag_name
    raise "invalid attribute" unless consume_char == "="
    value = parse_attr_value
    [name, value]
  end

  def parse_attr_value
    open_quote = consume_char
    raise "invalid attribute value" unless open_quote == "'" || open_quote == '"'
    value = consume_while { |char| char != open_quote }
    raise "invalid attribute value" unless consume_char == open_quote
    value
  end


  def parse_tag_name
    consume_while { |char| char =~ /\w/ }
  end

  def consume_text
    consume_while { |char| char != "<" }
  end

  def parse_text
    Text.new(consume_text)
  end

  def parse_node
    next_char == "<" ? parse_element : parse_text
  end
end
