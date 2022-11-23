if !has('nvim-0.5.0')
    echohl Error
    echom 'This plugin only works with Neovim >= v0.5.0'
    echohl clear
    finish
endif

if &compatible || exists('g:decipher#loaded')
    finish
endif

let s:cpo_save = &cpoptions

" Return the current version
function! DecipherVersion() abort
    return v:lua.require('decipher').version()
endfunction

nnoremap <silent> <Plug>(DecipherEncode) :lua require('decipher').encode()
nnoremap <silent> <Plug>(DecipherDecode) :lua require('decipher').decode()
vnoremap <silent> <Plug>(DecipherEncode) :lua require('decipher').encode_selection('base64')<cr>
vnoremap <silent> <Plug>(DecipherDecode) :lua require('decipher').decode_selection('base64')<cr>
vnoremap <silent> <Plug>(DecipherEncodePrompt) :lua require('decipher').encode_selection_prompt()<cr>
vnoremap <silent> <Plug>(DecipherDecodePrompt) :lua require('decipher').decode_selection_prompt()<cr>

" TODO: Make 'base64-url' into 'Base64Url'
function s:TitleCase(string) abort
    return toupper(a:string[0]) .. tolower(a:string[1:])
endfunction

for codec_name in v:lua.require('decipher').codecs()
    let titlecase_codec_name = s:TitleCase(codec_name)

    " Visual selections
    execute printf("vnoremap <silent> <Plug>(DecipherEncode%s) :lua require('decipher').encode_selection('%s')<cr>", titlecase_codec_name, codec_name)
    execute printf("vnoremap <silent> <Plug>(DecipherDecode%s) :lua require('decipher').decode_selection('%s')<cr>", titlecase_codec_name, codec_name)

    " Motions
    execute printf("nnoremap <silent> <expr> <Plug>(DecipherEncode%sMotion) <SID>DecipherEncodeMotion('%s')", titlecase_codec_name, codec_name)
    execute printf("nnoremap <silent> <expr> <Plug>(DecipherDecode%sMotion) <SID>DecipherDecodeMotion('%s')", titlecase_codec_name, codec_name)

    " Previews
    execute printf("vnoremap <silent> <Plug>(DecipherPreview%s) :lua require('decipher').decode_preview_selection('%s')<cr>", titlecase_codec_name, codec_name)
endfor

function! s:IsMotionType(type) abort
    return index(['block', 'char', 'line'], a:type) > -1
endfunction

function! s:DecipherEncodeMotion(codec_name) abort
    if !s:IsMotionType(a:codec_name)
        let b:_decipher_motion_codec_name = a:codec_name
        set operatorfunc=function('s:DecipherEncodeMotion')
        return 'g@'
    endif

    lua require('decipher').encode_motion(vim.b._decipher_motion_codec_name, '')
    unlet! b:_decipher_motion_codec_name
endfunction

function! s:DecipherDecodeMotion(codec_name) abort
    if !s:IsMotionType(a:codec_name)
        let b:_decipher_motion_codec_name = a:codec_name
        set operatorfunc=function('s:DecipherDecodeMotion')
        return 'g@'
    endif

    lua require('decipher').decode_motion(vim.b._decipher_motion_codec_name, '')
    unlet! b:_decipher_motion_codec_name
endfunction

function s:CompleteCodecs(arg_lead, cmdline, cursor_pos) abort
    return v:lua.require('decipher').codecs()
endfunction

command! DecipherVersion :echo DecipherVersion()<cr>
command! -range -nargs=+ DecipherEncode lua print(require('decipher').encode(<f-args>, <line1>, <line2>))
command! -range -nargs=+ DecipherDecode lua print(require('decipher').decode(<f-args>, <line1>, <line2>))
command! -range -nargs=1 -complete=customlist,s:CompleteCodecs DecipherEncodeSelection lua require('decipher').encode_selection(<f-args>)
command! -range -nargs=1 -complete=customlist,s:CompleteCodecs DecipherDecodeSelection lua require('decipher').decode_selection(<f-args>)
command! -range -nargs=1 -complete=customlist,s:CompleteCodecs DecipherPreviewSelection lua require('decipher').decode_preview_selection(<f-args>)

let g:deciper#loaded = 1
let &cpoptions = s:cpo_save
