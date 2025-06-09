augroup set_jenkins_groovy
  au!
  au BufNewFile,BufRead *.jenkinsfile,*.Jenkinsfile,Jenkinsfile,jenkinsfile setf groovy
augroup END

" get a list of troubled files and open them in the trouble quickfix buffer
function! GetInTrouble()
   if filereadable('pyproject.toml')
     let troubled_files = system("poetry run pyright --outputjson | jq -r '.generalDiagnostics[]|.file' | sort | uniq")
     for f in split(troubled_files)
       execute "new " . f
       q
     endfor
  "give pyright a second to catch up
  sleep 1000m
  lua require('trouble').open({ mode = "diagnostics"})
  endif
endfunction

nnoremap <C-s-T> :call GetInTrouble()<CR>
