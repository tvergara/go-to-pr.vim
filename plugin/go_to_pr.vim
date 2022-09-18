if (exists('g:loaded_go_to_pr'))
  finish
endif
let g:loaded_go_to_pr = 1

command! -nargs=0 GoToPR call go_to_pr#open_pr_page()
