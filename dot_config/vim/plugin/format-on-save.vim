vim9script
# Format on save, ported from the conform.nvim setup in ~/.config/nvim.
# Each filetype has a chain of formatters. Unavailable ones are skipped; if
# none are available, the attached language server formats instead.
# Unlike conform there is no timeout, so a hung formatter blocks the save.

def Root(markers: list<string>): string
    var start = escape(expand('%:p:h'), ' ,') .. ';'
    var best = ''
    for marker in markers
        var found = findfile(marker, start)
        if found != '' && len(fnamemodify(found, ':p:h')) > len(best)
            best = fnamemodify(found, ':p:h')
        endif
    endfor
    return best
enddef

def NodeBin(name: string): string
    var local = findfile($'node_modules/.bin/{name}', escape(expand('%:p:h'), ' ,') .. ';')
    return local != '' ? fnamemodify(local, ':p') : name
enddef

def RustEdition(): string
    var manifest = findfile('Cargo.toml', escape(expand('%:p:h'), ' ,') .. ';')
    if manifest != ''
        for line in readfile(manifest)
            var edition = line->matchstr('^\s*edition\s*=\s*["'']\zs\d\+')
            if edition != ''
                return edition
            endif
        endfor
    endif
    return '2021'
enddef

# oxfmt and prettier disagree about where to break call arguments, so use
# oxfmt only where the project configures it and prettier everywhere else.
const oxfmt_markers = ['.oxfmtrc.json', '.oxfmtrc.jsonc', 'oxfmt.config.ts']

# '$FILENAME' and '$DIRNAME' are replaced when a formatter runs.
def Chain(ft: string): list<dict<any>>
    if ft == 'awk'
        # conform runs plain `awk`, which on macOS executes the file instead
        # of pretty-printing it. Only gawk supports -o.
        return [{cmd: ['gawk', '-f', '-', '-o-']}]
    elseif ft == 'fish'
        return [{cmd: ['fish_indent']}]
    elseif ft == 'go'
        return [{cmd: ['goimports', '-srcdir', '$DIRNAME']}, {cmd: ['gofmt']}]
    elseif ft == 'json'
        return [{cmd: ['jq', '--indent', string(max([-1, min([7, shiftwidth()])]))]}]
    elseif ft == 'lua'
        return [{
            cmd: ['stylua', '--search-parent-directories', '--respect-ignores', '--stdin-filepath', '$FILENAME', '-'],
            cwd: Root(['.stylua.toml', 'stylua.toml']),
        }]
    elseif ft == 'markdown'
        return [{cmd: ['cbfmt', '--write', '--best-effort', '$FILENAME'], stdin: false, cwd: Root(['.cbfmt.toml'])}]
    elseif ft == 'terraform'
        return [{cmd: ['tofu', 'fmt', '-']}]
    elseif ft == 'yaml'
        return [{cmd: ['prettierd', '$FILENAME']}]
    elseif ft == 'python'
        var cwd = Root(['pyproject.toml', 'ruff.toml', '.ruff.toml'])
        return [
            {cmd: ['ruff', 'check', '--fix', '--force-exclude', '--select=I001', '--exit-zero', '--no-cache', '--stdin-filename', '$FILENAME', '-'], cwd: cwd},
            {cmd: ['ruff', 'format', '--force-exclude', '--stdin-filename', '$FILENAME', '-'], cwd: cwd},
        ]
    elseif ft == 'rust'
        return [{cmd: ['rustfmt', '--emit=stdout', $'--edition={RustEdition()}'], cwd: Root(['rustfmt.toml', '.rustfmt.toml'])}]
    elseif ft == 'sh'
        var cmd = ['shfmt', '-i', '4', '-filename', '$FILENAME']
        if Root(['.editorconfig']) == '' && &expandtab
            cmd += ['-i', string(shiftwidth())]
        endif
        return [{cmd: cmd}]
    elseif ft == 'toml'
        return [{cmd: ['taplo', 'format', '--stdin-filepath', '$FILENAME', '-']}]
    elseif ft == 'javascript' || ft == 'typescript'
        if Root(oxfmt_markers) != ''
            return [{cmd: [NodeBin('oxfmt'), '--stdin-filepath', '$FILENAME']}]
        endif
        # First available only, like conform's stop_after_first.
        for f in [{cmd: ['prettierd', '$FILENAME']}, {cmd: [NodeBin('prettier'), '--stdin-filepath', '$FILENAME']}]
            if executable(f.cmd[0])
                return [f]
            endif
        endfor
    endif
    return []
enddef

# Runs one formatter over lines and returns its output. Throws on failure.
def Run(f: dict<any>, lines: list<string>): list<string>
    var stdin = get(f, 'stdin', true)
    var tmp = stdin ? '' : $'{expand("%:p:h")}/.fmt.{getpid()}.{expand("%:t")}'
    var filename = stdin ? expand('%:p') : tmp
    var args = f.cmd->mapnew((_, a) => a == '$FILENAME' ? filename : a == '$DIRNAME' ? expand('%:p:h') : a)
    var errfile = tempname()
    var cmd = args->mapnew((_, a) => shellescape(a))->join() .. $' 2>{shellescape(errfile)}'
    if get(f, 'cwd', '') != ''
        cmd = $'cd {shellescape(f.cwd)} && {cmd}'
    endif

    var out: list<string>
    try
        if stdin
            out = systemlist(cmd, lines->join("\n") .. "\n")
        else
            writefile(lines, tmp)
            system(cmd)
            out = readfile(tmp)
        endif
    finally
        if tmp != ''
            delete(tmp)
        endif
    endtry

    var failed = v:shell_error != 0
    var errors = filereadable(errfile) ? readfile(errfile) : []
    delete(errfile)
    if failed
        throw $'format: {args[0]} failed: {errors->join(" ")}'
    endif
    # A formatter that prints nothing for a non-empty file is broken, not done.
    if out->empty() && lines->join('') =~ '\S'
        throw $'format: {args[0]} returned no output'
    endif
    return out
enddef

# Replaces only the changed middle of the buffer, so marks and the cursor
# outside it stay put.
def Apply(new: list<string>)
    var old = getline(1, '$')
    if new == old
        return
    endif
    var start = 0
    while start < len(old) && start < len(new) && old[start] == new[start]
        start += 1
    endwhile
    var end_old = len(old) - 1
    var end_new = len(new) - 1
    while end_old >= start && end_new >= start && old[end_old] == new[end_new]
        end_old -= 1
        end_new -= 1
    endwhile

    var old_count = end_old - start + 1
    var new_count = end_new - start + 1
    var common = min([old_count, new_count])
    var view = winsaveview()
    if common > 0
        setline(start + 1, new[start : start + common - 1])
    endif
    if new_count > old_count
        append(start + common, new[start + common : end_new])
    elseif old_count > new_count
        deletebufline('%', start + common + 1, start + old_count)
    endif
    winrestview(view)
enddef

def LspFormat()
    if exists('*g:LspServerReady') && g:LspServerReady()
        silent! LspFormat
    endif
enddef

def FormatOnSave()
    if &buftype != '' || expand('%') == '' || !&modifiable
        return
    endif
    var chain = Chain(&filetype)->filter((_, f) => executable(f.cmd[0]) == 1)
    if chain->empty()
        LspFormat()
        return
    endif
    var lines = getline(1, '$')
    try
        for f in chain
            lines = Run(f, lines)
        endfor
    catch /^format:/
        echohl ErrorMsg
        echomsg v:exception->substitute('^format: ', '', '')
        echohl None
        return
    endtry
    Apply(lines)
enddef

augroup format_on_save
    autocmd!
    autocmd BufWritePre * FormatOnSave()
augroup END
