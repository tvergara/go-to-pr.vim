function! go_to_pr#open_pr_page()
  let l:remote_url = s:get_remote_url()
  let l:browser_executable = s:get_browser()
  let l:file_path = expand('%:p')
  let l:hash = s:get_commit_hash()
  let l:commit_url = s:build_commit_url(l:remote_url, l:hash)

  return s:system_async(escape(printf('%s %s', l:browser_executable, l:commit_url), '?&%'))
endfunction

function! s:build_commit_url(remote_url, hash)
  return printf('%s/commit/%s', a:remote_url, a:hash)
endfunction

function! s:get_commit_hash()
  let l:line_number = line('.')
  let l:file_path = expand('%:p')
  let l:commit_response = system(printf('git log -L %d,%d:%s -1 --pretty=format:"%%H"', l:line_number, l:line_number, l:file_path))
  let l:commit_hash = split(l:commit_response)[0]
  return l:commit_hash
endfunction

function! s:get_browser() abort
  if !empty(g:create_pr_browser)
    return g:create_pr_browser
  endif

  if executable('xdg-open')
    return 'xdg-open'
  endif

  if has('win32')
    return 'start'
  endif

  if executable('open')
    return 'open'
  endif

  if executable('google-chrome')
    return 'google-chrome'
  endif

  if executable('firefox')
    return 'firefox'
  endif

  throw 'Browser not found'
endfunction

function! s:get_remote_url() abort
  let l:remote_url = s:system('git config --get remote.origin.url')
  let l:remote_url_trimmed = substitute(l:remote_url, '.git$', '', '')

  return l:remote_url_trimmed
endfunction

function! s:system_async(cmd) abort
  echo a:cmd
  if has('nvim') && exists('*jobstart')
    return jobstart(a:cmd, { 'detach': v:true })
  endif

  if exists('*job_start')
    return job_start(a:cmd, { 'stoponexit': '' })
  endif

  return s:system(a:cmd)
endfunction

function! s:system(cmd) abort
  let l:output = systemlist(a:cmd)
  return get(l:output, 0, '')
endfunction
