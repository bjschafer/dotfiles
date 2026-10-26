vim9script
# Guard rails for chezmoi-managed dotfiles, mirroring lua/configs/chezmoi in ~/.config/nvim:
#   * opening a target generated from a template marks it readonly and points at the source
#   * opening a modify_ target (app-owned JSON with some managed keys) says which keys are managed
#   * saving a plain managed target nudges toward `chezmoi re-add`
#   * saving a file in the source dir applies it
# :ChezmoiSource opens the source of the current target; :ChezmoiReAdd re-adds it.

if !executable('chezmoi')
    finish
endif

const home = expand('~')
var source_dir = ''
var by_target: dict<string> = {}
var by_source: dict<string> = {}
var loaded = false

def Notify(msg: string, hl = 'WarningMsg')
    execute $'echohl {hl}'
    echomsg $'chezmoi: {msg}'
    echohl None
enddef

# Map targets <-> sources once per session (chezmoi managed takes ~10ms), and
# again after saving in the source dir, since that may add files.
def Load()
    loaded = true
    by_target = {}
    by_source = {}
    source_dir = trim(system('chezmoi source-path'))
    var out = system('chezmoi managed --include=files --path-style=all --format=json')
    if v:shell_error != 0
        return
    endif
    var entries: dict<any>
    try
        entries = json_decode(out)
    catch
        return
    endtry
    for e in values(entries)
        by_target[e.absolute] = e.sourceAbsolute
        by_source[e.sourceAbsolute] = e.absolute
    endfor
enddef

def Kind(source: string): string
    var name = fnamemodify(source, ':t')
    if name =~ '^modify_'
        return 'modify'
    elseif name =~ '\.tmpl$'
        return 'template'
    endif
    return 'plain'
enddef

def UnderHome(path: string): bool
    return path[: len(home)] == $'{home}/'
enddef

def OnRead(buf: number, path: string)
    if !UnderHome(path)
        return
    endif
    if !loaded
        Load()
    endif
    var source = get(by_target, path, '')
    if source == ''
        return
    endif
    setbufvar(buf, 'chezmoi_source', source)
    var kind = Kind(source)
    if kind == 'template'
        setbufvar(buf, '&readonly', 1)
        Notify('generated from a template; edits here get overwritten. :ChezmoiSource to edit the template')
    elseif kind == 'modify'
        Notify('partly managed: keys in the managed JSON under .chezmoitemplates/ are reset on apply')
    endif
enddef

def OnWrite(buf: number, path: string)
    if !UnderHome(path)
        return
    endif
    if !loaded
        Load()
    endif

    var source = getbufvar(buf, 'chezmoi_source', '')
    if source != ''
        if Kind(source) == 'template'
            Notify('this file is generated; the next apply will overwrite your change', 'ErrorMsg')
        elseif Kind(source) == 'plain'
            Notify('managed file changed in place; :ChezmoiReAdd (or `chezmoi re-add`) to keep it', 'None')
        endif
        return
    endif

    if source_dir == '' || path[: len(source_dir)] != $'{source_dir}/'
        return
    endif
    if !has_key(by_source, path)
        Load()
    endif
    var target = get(by_source, path, '')
    if target == ''
        return # not a target itself (script, .chezmoitemplates/, ignore file, ...)
    endif
    # --no-tty: if the target changed since chezmoi last wrote it, fail instead of prompting
    var errors: list<string> = []
    job_start(['chezmoi', '--no-tty', 'apply', '--source-path', path], {
        err_cb: (_, line) => add(errors, line),
        exit_cb: (_, code) => code == 0
            ? Notify($'applied {fnamemodify(target, ':~')}', 'None')
            : Notify($'apply failed, run `chezmoi apply {target}`: {join(errors, ' ')}', 'ErrorMsg'),
    })
enddef

augroup chezmoi_guard
    autocmd!
    autocmd BufReadPost * OnRead(str2nr(expand('<abuf>')), expand('<afile>:p'))
    autocmd BufWritePost * OnWrite(str2nr(expand('<abuf>')), expand('<afile>:p'))
augroup END

command ChezmoiSource {
    if !exists('b:chezmoi_source')
        Notify("current file isn't managed by chezmoi")
    else
        execute $'edit {fnameescape(b:chezmoi_source)}'
    endif
}

# Runs in a terminal window: with git.autoCommit on, re-add prompts for a commit message.
command ChezmoiReAdd {
    if !exists('b:chezmoi_source')
        Notify("current file isn't managed by chezmoi")
    else
        term_start(['chezmoi', 're-add', expand('%:p')])
    endif
}
