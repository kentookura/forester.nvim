(comment) @comment

[
 "\\" 
 "("
 ")"
 "{"
 "}"
 "["
 "]"
] @punctuation.bracket

(p "p" @function.builtin)
(li "li" @markup.list)
(ul "ul"  @markup.list)
(ol "ol"  @markup.list)
(em "em"  @function.builtin)
(strong "strong" @function.builtin)
(code "code" @function.builtin)

(tex "tex" @function.builtin)

(ident (text) @field)

(subtree "subtree" @keyword.function)

(transclude "transclude" @include)
(transclude address: (_) @markup.link.url)

(def "def" @keyword)
(let "let" @keyword)
(object "object" @constant)
(object self: (_) @keyword)
(method_decl key: (_) @method)
(patch "patch" @text.diff.add)
(patch object: (_) @constant)

(markdown_link label: (_) @label)
(markdown_link dest: (_) @text.uri)
(unlabeled_link (external_link (_) @text.uri))

(scope "scope" @namespace)
(put "put" @variable.parameter)

(query_tree "query" @keyword)

(import "import" @include)
(export "export" @include)
(transclude "transclude" @include)


(li (text) @spell)
(em (text) @spell)
(strong (text) @spell)
(markdown_link label: (text) @spell)
(method_decl value: (method_body (text) @spell))
