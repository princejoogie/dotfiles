" ===============================================================
" joogie-dark
" 
" URL: https://github.com/princejoogie/joogie-dark.vim
" Author: Prince Carlo Juguilon
" License: MIT
" Last Change: 2022/03/20 05:55
" ===============================================================

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name="joogie-dark"

hi clear
hi ColorColumn guibg=#222222 ctermbg=235 gui=NONE cterm=NONE
hi Comment guifg=#637777 ctermfg=243 gui=NONE cterm=NONE
hi Constant guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi CursorLine guibg=#112630 ctermbg=235 gui=NONE cterm=NONE
hi CursorLineNr guifg=#aaaaaa ctermfg=248 guibg=#112630 ctermbg=235 gui=NONE cterm=NONE
hi DiffAdd guifg=#addb67 ctermfg=149 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi DiffChange guifg=#ce9178 ctermfg=222 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi DiffDelete guifg=#ff5874 ctermfg=204 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi DiffText guifg=#000000 ctermfg=233 guibg=#addb67 ctermbg=149 gui=NONE cterm=NONE
hi Directory guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi EndOfBuffer guifg=#444444 ctermfg=238 guibg=#000000 ctermbg=233 gui=NONE cterm=NONE
hi Exception guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi FloatBorder guifg=#112630 guibg=#112630 ctermbg=233 gui=NONE cterm=NONE
hi FoldColumn guifg=#333333 ctermfg=236 guibg=#000000 ctermbg=233 gui=NONE cterm=NONE
hi Folded guifg=#777777 ctermfg=243 guibg=#000000 ctermbg=233 gui=NONE cterm=NONE
hi GitGutterAdd guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi GitGutterChange guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi GitGutterChangeDelete guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi GitGutterDelete guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi Identifier guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi IncSearch guifg=#eeeeee ctermfg=255 guibg=#ce9178 ctermbg=222 gui=NONE cterm=NONE
hi IndentGuidesEven guibg=#777777 ctermbg=243 gui=NONE cterm=NONE
hi IndentGuidesOdd guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
hi LineNr guifg=#444444 ctermfg=238 guibg=#000000 ctermbg=233 gui=NONE cterm=NONE
hi NERDTreeClosable guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi NERDTreeDir guifg=#5f7e97 ctermfg=66 gui=NONE cterm=NONE
hi NERDTreeDirSlash guifg=#637777 ctermfg=243 gui=NONE cterm=NONE
hi NERDTreeHelp guifg=#444444 ctermfg=238 gui=NONE cterm=NONE
hi NERDTreeOpenable guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi NERDTreeUp guifg=#637777 ctermfg=243 gui=NONE cterm=NONE
hi NonText guifg=#444444 ctermfg=238 gui=NONE cterm=NONE
hi Normal guifg=#d6deeb ctermfg=253 guibg=#000000 ctermbg=233 gui=NONE cterm=NONE
hi NormalFloat guibg=#112630 ctermbg=233 gui=NONE cterm=NONE
hi Operator guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi PMenu guibg=#112630 ctermbg=236 gui=NONE cterm=NONE
hi PMenuSel guibg=#9cdcfe ctermbg=176 gui=NONE cterm=NONE
hi PreProc guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi Search guifg=#000000 ctermfg=233 guibg=#ce9178 ctermbg=222 gui=NONE cterm=NONE
hi SignColumn guifg=NONE ctermfg=NONE guibg=#000000 ctermbg=233 gui=NONE cterm=NONE
hi SpecialKey guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi Statement guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi StatusLine guifg=#eeeeee ctermfg=255 guibg=#112630 ctermbg=235 gui=NONE cterm=NONE
hi StatusLineNC guifg=#777777 ctermfg=243 guibg=#112630 ctermbg=235 gui=NONE cterm=NONE
hi StorageClass guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi String guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi Title guifg=#569cd6 ctermfg=111 gui=bold cterm=bold
hi Todo guifg=#777777 ctermfg=243 guibg=#ce9178 ctermbg=222 gui=NONE cterm=NONE
hi Type guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi VertSplit guifg=#777777 ctermfg=243 gui=NONE cterm=NONE
hi Visual guibg=#444444 ctermbg=236 gui=NONE cterm=NONE
hi cssBackgroundProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssBorderAttr guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi cssBorderProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssBoxProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssBraces guifg=#d6deeb ctermfg=253 gui=NONE cterm=NONE
hi cssClassName guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi cssColorProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssCommonAttr guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi cssDimensionProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssFontProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssIEUIProp guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi cssIdentifier guifg=#f4d554 ctermfg=221 gui=NONE cterm=NONE
hi cssIncludeKeyword guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssKeyFrameSelector guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi cssPositioningAttr guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi cssPositioningProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssPseudoClassId guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi cssTableAttr guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi cssTagName guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi cssTextProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssTransitionProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssUIProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi cssUnitDecorators guifg=#fbec9f ctermfg=229 gui=NONE cterm=NONE
hi cssValueLength guifg=#f78c6c ctermfg=209 gui=NONE cterm=NONE
hi diffAdded guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi diffRemoved guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi gitcommitSummary guifg=#d6deeb ctermfg=253 gui=NONE cterm=NONE
hi htmlBold guifg=#9cdcfe ctermfg=176 guibg=#000000 ctermbg=233 gui=bold cterm=bold
hi htmlH1 guifg=#569cd6 ctermfg=111 gui=bold cterm=bold
hi htmlH4 guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi htmlTag guifg=#637777 ctermfg=243 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
hi javaScriptBoolean guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi javaScriptBraces guifg=#d6deeb ctermfg=253 gui=NONE cterm=NONE
hi javaScriptConditional guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi javaScriptException guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi javaScriptFunction guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi javaScriptLineComment guifg=#637777 ctermfg=243 gui=NONE cterm=NONE
hi javaScriptReserved guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi javaScriptSpecial guifg=#f78c6c ctermfg=209 gui=NONE cterm=NONE
hi javaScriptStatement guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi javaScriptStringS guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi jsArrowFunction guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi jsBooleanFalse guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi jsBooleanTrue guifg=#ff5874 ctermfg=204 gui=NONE cterm=NONE
hi jsClassDefinition guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi jsComment guifg=#637777 ctermfg=243 gui=NONE cterm=NONE
hi jsConditional guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi jsExport guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi jsExportDefault guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi jsExtendsKeyword guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi jsFrom guifg=#c586c0 ctermfg=176 gui=NONE cterm=NONE
hi jsFuncCall guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi jsFuncName guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi jsFunction guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi jsImport guifg=#c586c0 ctermfg=176 gui=NONE cterm=NONE
hi jsModuleAs guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi jsNumber guifg=#f78c6c ctermfg=209 gui=NONE cterm=NONE
hi jsObjectProp guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi jsOperator guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi jsOperatorKeyword guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi jsRegexpString guifg=#5ca7e4 ctermfg=74 gui=NONE cterm=NONE
hi jsReturn guifg=#9cdcfe ctermfg=176 gui=NONE cterm=NONE
hi jsSpecial guifg=#f78c6c ctermfg=209 gui=NONE cterm=NONE
hi jsStorageClass guifg=#569cd6 ctermfg=111 gui=NONE cterm=NONE
hi jsString guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi link cssClassNameDot cssClassName
hi link htmlEndTag htmlTag
hi link htmlH2 htmlH1
hi link htmlH3 htmlH1
hi link htmlH5 htmlH4
hi link jsParensError jsFuncParens
hi markdownCode guifg=#aaaaaa ctermfg=248 gui=NONE cterm=NONE
hi markdownCodeDelimiter guifg=#ce9178 ctermfg=222 gui=NONE cterm=NONE
hi markdownHeadingDelimiter guifg=#637777 ctermfg=243 gui=NONE cterm=NONE
hi mkdCodeDelimiter guifg=#637777 ctermfg=243 guibg=#000000 ctermbg=233 gui=NONE cterm=NONE
hi mkdCodeEnd guifg=#d6deeb ctermfg=253 gui=NONE cterm=NONE
hi mkdCodeStart guifg=#d6deeb ctermfg=253 gui=NONE cterm=NONE
hi mkdLinkDef guifg=#9cdcfe ctermfg=116 gui=NONE cterm=NONE
hi scssFunctionName guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi scssSelectorName guifg=#addb67 ctermfg=149 gui=NONE cterm=NONE
hi shComment guifg=#637777 ctermfg=243 guibg=#000000 ctermbg=233 gui=NONE cterm=NONE

let g:terminal_color_foreground = "#d6deeb"
let g:terminal_color_background = "#000000"
let g:terminal_color_0 = "#000000"
let g:terminal_color_8 = "#637777"
let g:terminal_color_1 = "#ff5874"
let g:terminal_color_2 = "#addb67"
let g:terminal_color_10 = "#addb67"
let g:terminal_color_3 = "#f78c6c"
let g:terminal_color_11 = "#f78c6c"
let g:terminal_color_4 = "#569cd6"
let g:terminal_color_12 = "#569cd6"
let g:terminal_color_5 = "#9cdcfe"
let g:terminal_color_13 = "#9cdcfe"
let g:terminal_color_6 = "#9cdcfe"
let g:terminal_color_14 = "#9cdcfe"
let g:terminal_color_7 = "#aaaaaa"
let g:terminal_color_15 = "#eeeeee"

