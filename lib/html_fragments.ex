defmodule HtmlFragments do
  import Phoenix.HTML, only: [html_escape: 1]

  defmacro __using__(_) do
    quote do
      import HtmlFragments
    end
  end

  @default_attrs [
    input: [type: :text],
    form: [method: :post],
    table: [border: 0, cellspacing: 0, cellpadding: 0]
  ]

  @regular_elements  [ :a, :abbr, :address, :article, :aside, :audio, :b, :bdo, :blockquote,
                       :body, :button, :canvas, :caption, :cite, :code, :colgroup, :command,
                       :datalist, :dd, :del, :details, :dfn, :div, :dl, :dt, :em, :fieldset, 
                       :figcaption, :figure, :footer, :form, :h1, :h2, :h3, :h4, :h5, :h6, 
                       :head, :header, :hgroup, :html, :i, :iframe, :ins, :kbd, 
                       :label, :legend, :li, :map, :mark, :menu, :meter, :nav, :noscript,
                       :object, :ol, :optgroup, :option, :output, :p, :pre, :progress, :q, 
                       :s, :samp, :script, :section, :select, :small, :span, :strong, :style, 
                       :sub, :summary, :sup, :svg, :table, :tbody, :td, :textarea, :tfoot, 
                       :th, :thead, :time, :title, :tr,  :ul, :var, :video ] |> MapSet.new

  @self_closing_elements  [ :area, :base, :br, :col, :embed, :hr, :img, :input, :keygen, :link,
                            :menuitem, :meta, :param, :source, :track, :wbr ] |> MapSet.new

  defmacro html_fragment(do: ast) do
    new_ast = Macro.prewalk(ast, &substitute_html_elements/1)
    quote do
      {:safe, result} = html_escape(unquote(new_ast))
      to_string(result)
    end
  end

  def tag(name, self_closing, attrs, do: content) do
    attrs_html = for {key, val} <- attrs, into: "", do: " #{key}=\"#{val}\""
    if self_closing do
      {:safe, "<#{name}#{attrs_html}/>"}
    else
      {:safe, content} = html_escape(content)
      {:safe, "<#{name}#{attrs_html}>#{content}</#{name}>"}
    end
  end

  defp substitute_html_elements({:__block__, _, elems}) do
    elems
  end
  defp substitute_html_elements({tag_name, meta, args}) do
    cond do
      MapSet.member?(@regular_elements, tag_name) ->
        args = prepare_args_for_regular_elements(tag_name, args)
        {:tag, meta, [tag_name, false | args]}
      MapSet.member?(@self_closing_elements, tag_name) ->
        args = prepare_args_for_selfclosing_elements(tag_name, args)
        {:tag, meta, [tag_name, true | args]}
      true ->
        {tag_name, meta, args}
    end
  end
  defp substitute_html_elements(other), do: other


  defp prepare_args_for_regular_elements(tag_name, args) do
    default_attrs = @default_attrs[tag_name] || []
    case args do
      [[do: content]] -> 
        [default_attrs, [do: content]]
      [attrs, [do: content]] ->
        [merge_attrs(default_attrs, attrs), [do: content]]
      [attrs, content] when is_binary(content) ->
        [merge_attrs(default_attrs, attrs), [do: content]]
      [content] when is_binary(content) ->
        [default_attrs, [do: content]]
      [attrs] ->
        [merge_attrs(default_attrs, attrs), [do: nil]]
      nil ->
        [default_attrs, [do: nil]]
      other -> 
        IO.puts "Incorrect args for the #{tag_name}: #{inspect(other)}"
        [default_attrs, [do: nil]]
    end
  end

  defp prepare_args_for_selfclosing_elements(tag_name, args) do
    default_attrs = @default_attrs[tag_name] || []
    case args do
      [attrs] ->
        [merge_attrs(default_attrs, attrs), [do: nil]]
      [] ->
        [default_attrs, [do: nil]]
      nil ->
        [default_attrs, [do: nil]]
      other ->
        IO.puts "Incorrect args for the #{tag_name}: #{inspect(other)}"
        [default_attrs, [do: nil]]
    end
  end

  defp merge_attrs(kw1, kw2_ast) do
    quote do: Keyword.merge(unquote(kw1), unquote(kw2_ast))
  end
end
