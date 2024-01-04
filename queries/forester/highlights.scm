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
  "import" 
  "export"
]
@include

[
"date"
"taxon"
] @field

[
"ul" 
"ol"
"p"
"code"
]@function.builtin


((let) @define)
(method key: (text) @method)

"tag" @tag
"def" @define
"object" @lsp.type.class
"scope" @field
"query" @keyword
(ident) @function
(comment) @comment
;(identifier) @field
;(arg) @variable
(em (text)) @text.emphasis
(addr) @text.emphasis 
(link_label) @label
(title (_)+ @text.title)

("taxon" @function.builtin (#set! conceal "🧬"))
(taxon ("\\") @conceal (#set! conceal ""))
(taxon ("{") @conceal (#set! conceal " "))
(taxon ("}") @conceal (#set! conceal ""))
(taxon (_)+ @number)

("date" @function.builtin (#set! conceal "📅"))
(date ("\\") @conceal (#set! conceal ""))
(date ("{") @conceal (#set! conceal " "))
(date ("}") @conceal (#set! conceal ""))
(date (_)+ @number)

("meta" @function.builtin (#set! conceal "🌐"))
(meta ("\\") @conceal (#set! conceal ""))
(meta ("{") @conceal (#set! conceal " "))
(meta ("}") @conceal (#set! conceal ""))
(meta (_)+ @number)


("scope" @function.builtin (#set! conceal "🎯"))
(scope ("\\") @conceal (#set! conceal ""))
(scope ("{") @conceal (#set! conceal " "))
(scope ("}") @conceal (#set! conceal ""))
(scope (_)+ @number)

(external_link) @text.uri


(tag (text) @field)

(link_dest dest: (_) @conceal (#set! conceal""))
(link_dest "(" @conceal (#set! conceal""))
(link_dest ")" @conceal (#set! conceal""))

(unlabeled_link "[[" @conceal (#set! conceal ""))
(unlabeled_link "]]" @conceal (#set! conceal ""))

(put ("put") @keyword @conceal(#set! conceal "!"))
(put ("\\") @conceal (#set! conceal ""))
((put identifier: (ident) @id @text.title) (#eq? @id "\\transclude/title") (#set! conceal "T"))

;"title"
("title" @text.title (#set! conceal ""))
(title ("\\") @conceal (#set! conceal ""))
(title ("{") @punctuation.delimiter (#set! conceal " "))
(title ("}") @punctuation (#set! conceal ""))

("tag" @tag (#set! conceal "🏷️"))
(tag ("\\") @conceal (#set! conceal ""))
(tag ("{") @punctuation.delimiter (#set! conceal ""))
(tag ("}") @punctuation (#set! conceal ""))

("transclude" @keyword (#set! conceal "↪"))
(transclude ("\\") @conceal (#set! conceal ""))
(transclude ("{") @punctuation.delimiter (#set! conceal " "))
(transclude ("}") @punctuation (#set! conceal ""))

("li" @operator (#set! conceal "▸"))
(li ("\\") @conceal (#set! conceal ""))
(li ("{") @punctuation.delimiter (#set! conceal " "))
(li ("}") @punctuation (#set! conceal ""))

("ul" @operator (#set! conceal "⬤"))
(ul ("\\") @conceal (#set! conceal ""))
(ul ("{") @punctuation.delimiter (#set! conceal " "))
(ul ("}") @punctuation (#set! conceal ""))

("ol" @operator (#set! conceal "↓"))
(ol ("\\") @conceal (#set! conceal ""))
(ol ("{") @punctuation.delimiter (#set! conceal " "))
(ol ("}") @punctuation (#set! conceal ""))

("p" @operator (#set! conceal "¶"))
(p ("\\") @conceal (#set! conceal ""))

("code" @operator (#set! conceal " "))
(code ("\\") @conceal (#set! conceal ""))
(code ("{") @punctuation.delimiter (#set! conceal " "))
(code ("}") @punctuation (#set! conceal ""))
