$env.config.color_config = {
  separator: "#474849"
  leading_trailing_space_bg: "#a3a5a6"
  header: "#06ea61"
  date: "#ea5ce2"
  filesize: "#03aeff"
  row_index: "#42fff9"
  bool: "#b53b50"
  int: "#06ea61"
  duration: "#b53b50"
  range: "#b53b50"
  float: "#b53b50"
  string: "#a3a5a6"
  nothing: "#b53b50"
  binary: "#b53b50"
  cellpath: "#b53b50"
  hints: dark_gray

  shape_garbage: { fg: "#dddfe0" bg: "#b53b50" }
  shape_bool: "#03aeff"
  shape_int: { fg: "#ea5ce2" attr: b }
  shape_float: { fg: "#ea5ce2" attr: b }
  shape_range: { fg: "#c9d364" attr: b }
  shape_internalcall: { fg: "#42fff9" attr: b }
  shape_external: "#42fff9"
  shape_externalarg: { fg: "#06ea61" attr: b }
  shape_literal: "#03aeff"
  shape_operator: "#c9d364"
  shape_signature: { fg: "#06ea61" attr: b }
  shape_string: "#06ea61"
  shape_filepath: "#03aeff"
  shape_globpattern: { fg: "#03aeff" attr: b }
  shape_variable: "#ea5ce2"
  shape_flag: { fg: "#03aeff" attr: b }
  shape_custom: { attr: b }
}

source /home/meow/.cache/zoxide/init.nu

def --env yy [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXX")
  yazi ...$args --cwd-file $tmp
  let cwd = (open $tmp)
  if $cwd != "" and $cwd != $env.PWD {
    cd $cwd
  }
  rm -fp $tmp
}

use /home/meow/.cache/starship/init.nu

alias la = eza -a
alias ll = eza -l
alias lla = eza -la
alias ls = eza
alias lt = eza --tree