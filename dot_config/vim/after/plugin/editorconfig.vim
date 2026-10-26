vim9script
# The bundled editorconfig plugin reads <afile> on VimEnter, which fails with
# E495 when Vim starts without a file. BufReadPost/BufNewFile already cover
# files named on the command line.
silent! autocmd! editorconfig VimEnter
