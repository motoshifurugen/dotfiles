# Gitトレース用環境変数
export GIT_TRACE=1
export GIT_TRACE_PACK_ACCESS=1
export GIT_TRACE_SETUP=1

# ON/OFF切り替えエイリアス
alias enable-git-trace='export GIT_TRACE=1; export GIT_TRACE_PACK_ACCESS=1; export GIT_TRACE_SETUP=1'
alias disable-git-trace='unset GIT_TRACE GIT_TRACE_PACK_ACCESS GIT_TRACE_SETUP' 