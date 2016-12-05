# HTML fragments in Elixir

## Example usage

```elixir
defmodule Example do
  use HtmlFragments

  def generate do
    html_fragment do
      h1 "Header"
      div id: "main", "data-id": "7" do
        p "foo"
        hr class: "sep"
        p "bar"
      end
    end
  end
end
```

`Example.generate` will render the following:

```
"<h1>Header</h1><div id=\"main\" data-id=\"7\"><p>foo</p><hr class=\"sep\"/><p>bar</p></div>"
```


## Installation

  Add `html_fragments` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:html_fragments, github: "romul/html_fragments"}]
  end
  ```
