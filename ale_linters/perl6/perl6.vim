" Author: Nate Brown <https://github.com/nbrown>
" Description: This file adds support for checking perl6 syntax

let g:ale_perl6_perl6_executable =
\   get(g:, 'ale_perl6_perl6_executable', 'perl6')

let g:ale_perl6_perl6_options =
\   get(g:, 'ale_perl6_perl6_options', '-c -Ilib')

function! ale_linters#perl6#perl6#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'perl6_perl6_executable')
endfunction

function! ale_linters#perl6#perl6#GetCommand(buffer) abort
    return ale_linters#perl6#perl6#GetExecutable(a:buffer)
    \   . ' ' . ale#Var(a:buffer, 'perl6_perl6_options')
    \   . ' %t'
endfunction

let s:begin_failed_skip_pattern = '\v' . join([
\   '^Compilation failed in require',
\   '^Can''t locate',
\], '|')

function! ale_linters#perl6#perl6#Handle(buffer, lines) abort
    "let l:pattern = '\(.\+\)\nat \(.\+\):\(\d\+\)'
    let l:pattern = 'at \(.\+\):\(\d\+\)'
    let l:output = []

    for [l:match, l:line_num] in ale#util#GetMatches(a:lines, l:pattern, 'return-line-nums')
        let l:line = l:match[2]
        let l:text = a:lines[l:line_num-1]
        let l:type = 'E'

"        if ale#path#IsBufferPath(a:buffer, l:match[2])
"        \ && (
"        \   l:text !=# 'BEGIN failed--compilation aborted'
"        \   || empty(l:output)
"        \   || match(l:output[-1].text, s:begin_failed_skip_pattern) < 0
"        \ )
            call add(l:output, {
            \   'lnum': l:line,
            \   'text': l:text,
            \   'type': l:type,
            \})
"        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('perl6', {
\   'name': 'perl6',
\   'executable_callback': 'ale_linters#perl6#perl6#GetExecutable',
\   'output_stream': 'both',
\   'command_callback': 'ale_linters#perl6#perl6#GetCommand',
\   'callback': 'ale_linters#perl6#perl6#Handle',
\})
