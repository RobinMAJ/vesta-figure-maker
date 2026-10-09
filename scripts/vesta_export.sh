#!/bin/zsh
set -eu

usage() {
  print -u2 "Usage: vesta_export.sh INPUT OUTPUT [SCALE]"
  print -u2 "Example: vesta_export.sh scene.vesta figure.png 4"
}

if (( $# < 2 || $# > 3 )); then
  usage
  exit 2
fi

input_path=$1
output_path=$2
scale=${3:-4}
vesta_app=/Applications/VESTA.app
timeout_seconds=${VESTA_EXPORT_TIMEOUT_SECONDS:-90}

if [[ ! -f "$input_path" ]]; then
  print -u2 "Input file not found: $input_path"
  exit 3
fi

if [[ ! -d "$vesta_app" ]]; then
  print -u2 "VESTA is not installed at $vesta_app"
  exit 4
fi

if [[ "$scale" != <-> || "$scale" -lt 1 ]]; then
  print -u2 "SCALE must be a positive integer: $scale"
  exit 5
fi

if [[ -e "$output_path" ]]; then
  print -u2 "Refusing to overwrite existing output: $output_path"
  exit 6
fi

output_dir=${output_path:h}
if [[ ! -d "$output_dir" ]]; then
  print -u2 "Output directory does not exist: $output_dir"
  exit 7
fi

input_abs=${input_path:A}
output_abs=${output_path:A}

open -n -a VESTA.app --args \
  -open "$input_abs" \
  -export_img "scale=$scale" "$output_abs"

elapsed=0
previous_size=-1
stable_checks=0

while (( elapsed < timeout_seconds )); do
  if [[ -s "$output_abs" ]]; then
    current_size=$(stat -f %z "$output_abs")
    if [[ "$current_size" -eq "$previous_size" ]]; then
      (( stable_checks += 1 ))
    else
      stable_checks=0
      previous_size=$current_size
    fi
    if (( stable_checks >= 2 )); then
      print "Exported: $output_abs"
      sips -g pixelWidth -g pixelHeight -g format "$output_abs"
      exit 0
    fi
  fi
  sleep 1
  (( elapsed += 1 ))
done

print -u2 "Timed out after ${timeout_seconds}s waiting for VESTA export: $output_abs"
exit 8
