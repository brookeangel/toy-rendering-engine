require_relative './html_parser.rb'
require_relative './css_parser.rb'
require_relative './style_tree.rb'

html = HTMLParser.new(<<-HTML).parse
  <html>
    <h1>Hello World</h1>
    <div class="note">
      This is an HTML Document.
      <p id="answer">
        I sure hope it works.
      </p>
    </div>
  </html>
HTML

stylesheet = StyleSheet.new(<<-CSS)

h1, h2, h3 {
  margin: auto;
  color: #cc0000;
}

div.note {
  margin-bottom: 20px;
  padding: 10px;
}

#answer {
  display: none;
}

CSS

style_tree = StyleNode.new(html, stylesheet)
