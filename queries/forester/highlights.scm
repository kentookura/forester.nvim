[
 "{"
 "}"
 "("
 ")"
 "["
 "]"
 "\\"
]
@punctuation.delimiter

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
"li"
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
;;(identifier) @field
;;(arg) @variable
(em (text)) @text.emphasis
(addr) @underline 
(label) @text.uri
(title (_)* @text.title)
(date (_)* @text.title)
(link_dest dest: (_) @variable)
(external_link) @text.underline
