#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')

RST=$'\033[0m'
GRN=$'\033[32m'
YEL=$'\033[33m'
CYN=$'\033[36m'
MAG=$'\033[35m'
RED=$'\033[31m'
DIM=$'\033[90m'
SEP="${DIM}·${RST}"

full_path=$(echo "$cwd" | sed "s|^$HOME|~|")
short_path=$(echo "$full_path" | awk -F'/' '{
  n=NF
  if (n==1) { print $1 }
  else if (n==2) { print $1 "/" $2 }
  else { print $(n-1) "/" $n }
}')
host=$(hostname -s)
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
  || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

sess_in=""
sess_out=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  read -r sess_in sess_out < <(jq -n -r '
    reduce inputs as $l ({i:0,o:0};
      .i += (($l.message.usage.input_tokens // 0)
           + ($l.message.usage.cache_creation_input_tokens // 0)
           + ($l.message.usage.cache_read_input_tokens // 0))
      | .o += ($l.message.usage.output_tokens // 0))
    | "\(.i) \(.o)"' "$transcript" 2>/dev/null)
fi

fmt_tokens() {
  local n="$1"
  if [ -z "$n" ] || [ "$n" = "null" ] || [ "$n" = "0" ]; then
    echo ""
    return
  fi
  echo "$n" | awk '{
    v=$1; u="";
    if (v>=1000000) { v/=1000000; u="M" }
    else if (v>=1000) { v/=1000; u="k" }
    if (u=="") printf "%d", v
    else if (v==int(v)) printf "%d%s", v, u
    else printf "%.1f%s", v, u
  }'
}

in_fmt=$(fmt_tokens "$sess_in")
out_fmt=$(fmt_tokens "$sess_out")
base="${GRN}${host}${RST}  ${short_path}"
[ -n "$branch" ] && base="${base}  ${YEL}‹${branch}›${RST}"
metrics=()

if [ -n "$used_pct" ]; then
  pct_int=$(printf "%.0f" "$used_pct")
  if [ "$pct_int" -ge 80 ]; then ctx_color="$RED"
  elif [ "$pct_int" -ge 50 ]; then ctx_color="$YEL"
  else ctx_color="$GRN"
  fi
  read -r full eighths < <(awk -v p="$pct_int" 'BEGIN{
    w=10; f=p/100*w; full=int(f); e=int((f-full)*8+0.5);
    if (e>=8) { full++; e=0 }
    if (full>w) { full=w; e=0 }
    print full, e
  }')
  partials=( "" "▏" "▎" "▍" "▌" "▋" "▊" "▉" )
  bar="▕"
  for ((i=0;i<full;i++)); do bar+="█"; done
  used=$full
  if [ "$eighths" -gt 0 ]; then bar+="${partials[$eighths]}"; used=$((full+1)); fi
  for ((i=used;i<10;i++)); do bar+="░"; done
  bar+="▏"
  metrics+=("${ctx_color}${bar} ${pct_int}%${RST}")
fi

[ -n "$in_fmt" ] && [ -n "$out_fmt" ] && metrics+=("${CYN}↑${in_fmt} ↓${out_fmt}${RST}")
if [ -n "$cost_usd" ]; then
  cost_fmt=$(echo "$cost_usd" | awk '{ if ($1>=1) printf "$%.2f",$1; else printf "$%.3f",$1 }')
  metrics+=("${MAG}${cost_fmt}${RST}")
fi

out="$base"
if [ "${#metrics[@]}" -gt 0 ]; then
  out="${out}  ${SEP}  ${metrics[0]}"
  for ((i=1;i<${#metrics[@]};i++)); do out="${out}  ${SEP}  ${metrics[i]}"; done
fi
printf '%s' "$out"
