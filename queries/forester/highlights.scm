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

(paragraph "p" @function.builtin)
(li "li" @markup.list)
(ul "ul"  @markup.list)
(ol "ol"  @markup.list)
(em "em"  @function.builtin)
(strong "strong" @function.builtin)
(code "code" @function.builtin)

(tag "tag" @field)
(author "author" @field)
(contributor "contributor" @field)
(title "title" @field)
(taxon "taxon" @field)

(title "title" @text.title)
(title (_) @text.title)
(author author: (_) @markup.heading.url)

(ident label: (_) @string)
(transclude "transclude" @include)
(transclude address: (_) @markup.link.url)

(def "def" @keyword)
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
;(query_author "query/author" @keyword)
;(query_tag "query/tag" @keyword)
;(query_taxon "query/taxon" @keyword)
;(query_and "query/and" @keyword)
;(query_or "query/or" @keyword)
;(query_meta "query/meta" @keyword)

(import "import" @include)
(export "export" @include)
(transclude "transclude" @include)

