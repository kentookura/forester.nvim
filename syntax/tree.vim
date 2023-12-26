"syn keyword foresterKeywords export put get tag namespace open meta tex block texpackage query xml highlight link foresterKeywords Keyword
"
"
"syn keyword foresterFunctions date title taxon author scope em strong li ul ol code blockquote pre object patch call
"highlight link foresterFunctions Function
"
"syn keyword foresterConditional iftex 
"highlight link foresterConditional Conditional
"
"syn keyword foresterIncludes transclude import 
"highlight link foresterIncludes Include 
"
"syn keyword foresterDefine def alloc let
"highlight link foresterDefine Define
"
"syntax match foresterComment "%.*$"
"highlight link foresterComment Comment
"
"
"syntax region displayTex start=/##{/ end=/}/ contains=@tex keepend
"syntax region inlineTex start=/#{/ end=/}/ contains=@tex keepend

