defmodule HtmlFragmentsTest do
  use ExUnit.Case
  doctest HtmlFragments
  use HtmlFragments

  test "empty block" do
    result = html_fragment do  
    end

    assert result == ""
  end

  test "simple element" do
    result = html_fragment do
      p "Test"
    end

    assert result == "<p>Test</p>"
  end

  test "simple self-closing element" do
    result = html_fragment do
      br
    end

    assert result == "<br/>"
  end

  test "simple element with attrs" do
    result = html_fragment do
      div id: "content", class: "row" do
        "Test"
      end
    end

    assert result == "<div id=\"content\" class=\"row\">Test</div>"
  end

  test "several simple elements" do
    result = html_fragment do
      p "1"
      p "2"
      p "3"
    end

    assert result == "<p>1</p><p>2</p><p>3</p>"
  end

  test "several simple elements inside other element" do
    result = html_fragment do
      div do
        p "1"
        p "2"
        p "3"
      end
    end

    assert result == "<div><p>1</p><p>2</p><p>3</p></div>"
  end

  test "multi elements fragment" do
    result = html_fragment do
      h1 "Header"
      div do
        p "foo"
        br
        p "bar"
      end
    end

    assert result == "<h1>Header</h1><div><p>foo</p><br/><p>bar</p></div>"
  end

  test "multi elements fragment with various attributes" do
    result = html_fragment do
      h1 "Header"
      div id: "main", "data-id": "7" do
        p "foo"
        hr class: "sep"
        p "bar"
      end
    end

    assert result == "<h1>Header</h1><div id=\"main\" data-id=\"7\"><p>foo</p><hr class=\"sep\"/><p>bar</p></div>"
  end

  test "escape content of element" do
    result = html_fragment do
      p "<script />"
    end

    assert result == "<p>&lt;script /&gt;</p>"
  end 

  test "script element" do
    result = html_fragment do
      script src: "http://www.someexamplesite.com/example.js", type: "text/javascript"
    end

    assert result == "<script src=\"http://www.someexamplesite.com/example.js\" type=\"text/javascript\"></script>"
  end

  test "a element (link)" do
    result = html_fragment do
      a [name: "example", href: "http://www.someexamplesite.com/"], "ExampleSite"
    end

    assert result == "<a name=\"example\" href=\"http://www.someexamplesite.com/\">ExampleSite</a>"
  end

  test "simple div" do
    result = html_fragment do
      div
    end
    assert result == "<div></div>"
  end

  test "nesting div span" do
    result = html_fragment do
      div do
        span
      end
    end
    assert result == "<div><span></span></div>"
  end

  test "attributes" do
    result = html_fragment do
      div class: "test"
    end
    assert result == "<div class=\"test\"></div>"
  end

  test "attributes with do" do
    result = html_fragment do
      div class: "test" do
        span
      end
    end
    assert result == "<div class=\"test\"><span></span></div>"
  end

  test "contents" do
    result = html_fragment do
      div "test"
    end
    assert result == "<div>test</div>"
  end

  test "creates an a" do
    result = html_fragment do
      a href: "/"
    end
    assert result == ~s(<a href="/"></a>)
  end


  test "includes content and attributes" do
    result = html_fragment do
      div([class: "my-class"], "Some content")
    end
    assert result == ~s(<div class="my-class">Some content</div>)
  end

  test "nests" do
    result = html_fragment do
      div do
        span "my span"
      end
    end
    assert result == "<div><span>my span</span></div>"
  end

  test "nests 3 deep" do
    result = html_fragment do
      div id: "one" do
        div id: "two" do
          div [id: "three"], "Inner"
        end
      end
    end
    assert result == ~s(<div id="one"><div id="two"><div id="three">Inner</div></div></div>)

  end

  test "two children" do
    result = html_fragment do
      div do
        div(id: "one")
        div(id: "two")
      end
    end
    assert result  == ~s(<div><div id="one"></div><div id="two"></div></div>)
  end

  test "self closing" do
    result = html_fragment do
      input
    end
    assert result == ~s(<input type="text"/>)
  end

  test "self closing with attributes" do
    result = html_fragment do
      input([type: :text] ++ [])
    end
    assert result == ~s(<input type="text"/>)
  end

  test "tag with attributes list" do
    result = html_fragment do
      div([class: :text] ++ [])
    end
    assert result == ~s(<div class="text"></div>)
  end

  test "tag with attributes list no parenthesis" do
    result = html_fragment do
      div [class: :text] ++ []
    end
    assert result == ~s(<div class="text"></div>)
  end

  test "tag with attributes list and do block" do
    result = html_fragment do
      div [class: :text] ++ [] do
        span
      end
    end
    assert result == ~s(<div class="text"><span></span></div>)
  end

  test "tag with contents attributes list and do block" do
    result = html_fragment do
      div [id: "id", class: :text] ++ [] do
        span
      end
    end
    assert result == ~s(<div id="id" class="text"><span></span></div>)
  end

  test "Example form" do
    expected = "<form method=\"post\" action=\"/model\" name=\"form\">" <>
               "<input type=\"text\" id=\"model[name]\" name=\"model_name\" value=\"my name\"/>" <>
               "<input type=\"hidden\" id=\"model[group_id]\" name=\"model_group_id\" value=\"42\"/>" <>
               "<input type=\"submit\" name=\"commit\" value=\"submit\"/>" <>
               "</form>"
    result = html_fragment do
      form method: :post, action: "/model", name: "form" do
        input(type: :text, id: "model[name]", name: "model_name", value: "my name")
        input(type: :hidden, id: "model[group_id]", name: "model_group_id", value: "42")
        input(type: :submit, name: "commit", value: "submit")
      end
    end
    assert result == expected
  end

  test "default type for input" do
    result = html_fragment do
      input(id: 1)
    end
    assert result  == ~s(<input type="text" id="1"/>)
  end

  test "support class and id attributes" do
    result = html_fragment do
      div class: "cls two", id: "ids"
    end
    assert result == ~s(<div class=\"cls two\" id=\"ids\"></div>)
  end

  test "doesn't fail with invalid inner block" do
    result = html_fragment do
      div do
        nil
      end
    end
    assert result == ~s(<div></div>)

    result = html_fragment do
      div do
        :ok
      end
    end
    assert result == ~s(<div>ok</div>)
  end
end
