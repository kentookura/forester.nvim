[
 "("
 ")"
 "["
 "]"
 "[["
 "]]"
]
@punctuation.delimiter

[
 "\\"
 "{"
 "}"
]
@punctuation.special


[
  "transclude" 
  "import" 
  "export"
]
@include

[
"title"
"date"
"taxon"
] @field

[
"ul" 
"ol"
"p"
"code"
]@function.builtin


"tag" @tag

"def" @define
"object" @lsp.type.class
"scope" @field
"put" @keyword
"query" @keyword

(ident) @function
;(identifier) @field
;(arg) @variable
(em (text)) @text.emphasis
(addr) @comment
;(label) @label
(title (_)+ @text.title)
(date (_)+ @text.title)
(link_dest dest: (_) @variable)
(external_link) @text.uri

("li" @operator (#set! conceal "•"))
(li ("{") @punctuation.delimiter (#set! conceal ""))
(li ("}") @punctuation (#set! conceal ""))
(li ("\\") @conceal (#set! conceal ""))
