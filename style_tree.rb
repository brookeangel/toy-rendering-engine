class StyleNode
  attr_reader :element, :specified_values, :children, :stylesheet

  def initialize(element, stylesheet)
    @element = element
    @stylesheet = stylesheet
    if !element.is_a?(Text)
      @specified_values = specified_values
      @children = element.children.map { |child| StyleNode.new(child, stylesheet) }
    else
      @specified_values = nil
      @children = nil
    end
  end

  private

  def specified_values
    values = {}
    rules = matching_rules.sort_by { |rule| rule[:specificity] }

    rules.each do |rule|
      rule[:rule].declarations.each do |declaration|
        values[declaration.name] = declaration.value
      end
    end

    values
  end

  def id
    element.attributes["id"]
  end

  def classes
    element.attributes["class"].split(" ")
  end

  def matches_simple_selector?(selector)
    return false if selector.tag_names.any? { |name| name != element.tag_name }
    return false if selector.ids.any? { |sel_id| sel_id != id }
    return false if selector.klasses.any? { |klass| !classes.include?(klass) }
    true
  end

  def matched_rule(rule)
    selector = rule.selectors.find { |selector| matches_simple_selector?(selector) }
    return {rule: rule, specificity: selector.specificity} if selector
  end

  def matching_rules
    stylesheet.rules.map { |rule| matched_rule(rule) }.compact
  end
end
