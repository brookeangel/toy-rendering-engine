class Node
  attr_reader :children

  def initialize(children = [])
    @children = children
  end

  def add_child(child)
    children << child
    child
  end

  def remove_child(child)
    children.delete(child)
    child
  end
end

class Element < Node
  attr_reader :attributes, :tag_name

  def initialize(name, children = [], attributes = {})
    @tag_name = name
    @attributes = attributes
    super(children)
  end

  def to_s
    str = tag_name
    str += "\n >" unless children.empty?
    str += children.join("> \n")
  end

  def set_attr(key, val)
    attributes[key] = val
  end

  def get_attr(key)
    attributes[key]
  end

  def remove_attr(key, val)
    attributes.delete(key)
  end
end

class Text < Node
  attr_reader :content

  def initialize(content)
    @content = content
    super([])
  end

  def to_s
    content
  end

  def add_child(child)
    raise "cannot add child to text node"
  end
end
