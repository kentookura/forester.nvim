(inline_math math: (ident (label) @label (#eq? @label "rho")(#set! conceal "ρ")))
(inline_math math: (ident (label) @label (#eq? @label "in")(#set! conceal "∈")))
(inline_math math: (ident (label) @label (#eq? @label "neq")(#set! conceal "≠")))
(inline_math math: (ident (label) @label (#eq? @label "qed") (#set! conceal "∎")))


[
 "("
 ")"
 "["
 "]"
 "[["
 "]]"
]
@punctuation.delimiter

;[
; "\\"
; "{"
; "}"
;]
;@punctuation.special


[
  "import" 
  "export"
]
@include

[
"date"
"taxon"
] @field

;; Prim

(p "p" @operator (#set! conceal "¶"))
(p ("\\") @conceal (#set! conceal ""))
(p ("{") @punctuation.delimiter) 
(p ("}") @punctuation.delimiter)

(li "li" @operator (#set! conceal "▸"))
(li ("\\") @conceal (#set! conceal ""))
(li ("{") @punctuation (#set! conceal " "))
(li ("}") @punctuation (#set! conceal ""))

(ul "ul" @operator (#set! conceal "⬤")) ;; Find better symbol
(ul ("\\") @conceal (#set! conceal ""))
(ul ("{") @punctuation (#set! conceal " "))
(ul ("}") @punctuation (#set! conceal ""))

(ol "ol" @operator (#set! conceal "1")) ;; Find better symbol
(ol ("\\") @conceal (#set! conceal ""))
(ol ("{") @punctuation (#set! conceal " "))
(ol ("}") @punctuation (#set! conceal ""))


(code "code" @operator (#set! conceal " "))
(code ("\\") @conceal (#set! conceal ""))
(code ("{") @punctuation.delimiter)
(code ("}") @punctuation.delimiter)
(code (_)* @text) 

(if_tex "iftex" @operator)
(if_tex ("\\") @conceal (#set! conceal ""))
(if_tex ("{") @punctuation.delimiter)
(if_tex ("}") @punctuation.delimiter)

(ident ((label) @label))

(ident ((label) @label) (#eq? @label "todo") (#set! conceal "☐ ")) ; FIXME conceal list item when making a todo list
(ident ((label) @label) (#eq? @label "done") (#set! conceal "☑ "))
;((let) @define)
;(method key: (text) @method)
 
"tag" @tag
"def" @define
"object" @lsp.type.class
"scope" @field
"query" @keyword
;(ident) @function
(comment) @comment
;(identifier) @field
;(arg) @variable
(addr) @text.emphasis 
(link_label) @label
(title (_)+ @text.title)

("strong" @conceal (#set! conceal ""))
(strong ("\\") @conceal (#set! conceal ""))
(strong ("{") @conceal (#set! conceal " "))
(strong ("}") @conceal (#set! conceal ""))
(strong (_)+ @text.strong)
 
("em" @conceal (#set! conceal ""))
(em ("\\") @conceal (#set! conceal ""))
(em ("{") @conceal (#set! conceal " "))
(em ("}") @conceal (#set! conceal ""))
(em (_)+ @text.emphasis)

("taxon" @function.builtin (#set! conceal "🧬"))
(taxon ("\\") @conceal (#set! conceal ""))
(taxon ("{") @punctuation.delimiter (#set! conceal " "))
(taxon ("}") @punctuation.delimiter (#set! conceal ""))
(taxon (_)+ @number)

("date" @function.builtin (#set! conceal "📅"))
(date ("\\") @conceal (#set! conceal ""))
(date ("{") @punctuation.delimiter (#set! conceal " ")) ;; space to hack font
(date ("}") @punctuation.delimiter (#set! conceal ""))
(date (_)+ @number)

("meta" @function.builtin (#set! conceal "🌐"))
(meta ("\\") @conceal (#set! conceal ""))
(meta ("{") @punctuation.delimiter (#set! conceal " ")) ;; space to hack font
(meta ("}") @punctuation.delimiter (#set! conceal ""))
(meta (_)+ @number)


("scope" @function.builtin (#set! conceal "▷"))
(scope ("\\") @conceal (#set! conceal ""))

(external_link) @text.uri


(tag (text) @field)

(link_dest dest: (_) @conceal (#set! conceal""))
(link_dest "(" @conceal (#set! conceal""))
(link_dest ")" @conceal (#set! conceal""))

(unlabeled_link "[[" @conceal (#set! conceal ""))
(unlabeled_link "]]" @conceal (#set! conceal ""))

(query_tag "\\query/tag" @tag (#set! conceal "🏷️"))
(query_tag (text) @lsp.type.enumMember) 

(put ("put") @lsp.type.modifier (#set! conceal "!"))
(put ("\\") @conceal (#set! conceal ""))
; (transclusion_opt "/" @conceal (#set! conceal " "))
; (put "transclude" @keyword) 
; ((put identifier: (ident) @identifier) (#eq? @identifier "\\transclude/title") (#set! conceal "T"))


;"title"
(title "title" @function.builtin (#set! conceal ""))
(title ("\\") @conceal (#set! conceal ""))
(title ("{") @punctuation.delimiter (#set! conceal ""))
(title ("}") @punctuation.delimiter (#set! conceal ""))

("tag" @tag (#set! conceal "🏷️"))
(tag ("\\") @conceal (#set! conceal ""))
(tag ("{") @punctuation.delimiter (#set! conceal ""))
(tag ("}") @punctuation.delimiter (#set! conceal ""))

("import" @keyword (#set! conceal "↧"))
(import ("\\") @conceal (#set! conceal ""))
(import ("{") @punctuation.delimiter (#set! conceal " "))
(import ("}") @punctuation.delimiter (#set! conceal ""))

("export" @keyword (#set! conceal "↥"))
(export ("\\") @conceal (#set! conceal ""))
(export ("{") @punctuation.delimiter (#set! conceal " "))
(export ("}") @punctuation.delimiter (#set! conceal ""))

("transclude" @keyword (#set! conceal "⨝"))
(transclude ("\\") @conceal (#set! conceal ""))
(transclude ("{") @punctuation.delimiter (#set! conceal " "))
(transclude ("}") @punctuation.delimiter (#set! conceal ""))

("query" @keyword (#set! conceal "🔍"))
(query_tree ("\\") @conceal (#set! conceal ""))
;
;
;(query ("{") @punctuation.delimiter )
;(query ("}") @punctuation.delimiter )

