#!/bin/bash
# CKA Killercoda practice labs - runner
#   ./lab.sh list                 list all questions
#   ./lab.sh <N>                  reset + set up lab N, then print the question
#   ./lab.sh <N> question         print the question again
#   ./lab.sh <N> validate         check your answer
#   ./lab.sh <N> solution         show the solution notes
#   ./lab.sh <N> cleanup          remove everything the lab (and your answer) created
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage(){ sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

if [ "$1" = "list" ] || [ -z "$1" ]; then
  echo "Available questions:"
  for d in "$ROOT"/Question-*; do
    n=$(basename "$d" | cut -d- -f2); t=$(basename "$d" | cut -d- -f3- | tr '-' ' ')
    printf "  %s  %s\n" "$n" "$t"
  done
  [ -z "$1" ] && echo && usage
  exit 0
fi

[[ "$1" =~ ^[0-9]+$ ]] || usage
N=$(printf "%02d" "$((10#$1))")
DIR=$(ls -d "$ROOT"/Question-"$N"-* 2>/dev/null | head -1)
[ -d "$DIR" ] || { echo "Question $1 not found. Run ./lab.sh list"; exit 1; }
ACTION="${2:-setup}"

case "$ACTION" in
  setup)
    echo "==> Setting up $(basename "$DIR") ..."
    bash "$DIR/LabSetUp.bash" || { echo "Setup reported an error - see above."; exit 1; }
    echo; echo "==> Question"; cat "$DIR/Question.bash"
    echo; echo "When finished:  ./lab.sh $((10#$N)) validate      Stuck?  ./lab.sh $((10#$N)) solution" ;;
  question) cat "$DIR/Question.bash" ;;
  validate) bash "$DIR/validate.sh" ;;
  solution) cat "$DIR/SolutionNotes.bash" ;;
  cleanup)  bash "$DIR/cleanup.sh" && echo "Cleanup done." ;;
  *) usage ;;
esac
