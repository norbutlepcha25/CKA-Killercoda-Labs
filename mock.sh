#!/bin/bash
# CKA Killercoda mock exams - runner (15 questions, 120 minutes each)
#   ./mock.sh list                         list the mock exams and their questions
#   ./mock.sh <E> start [minutes]          reset + set up every question of exam E and start the clock
#   ./mock.sh <E> questions                print all questions of exam E
#   ./mock.sh <E> time                     show the remaining time
#   ./mock.sh <E> score                    check every question and print your score
#   ./mock.sh <E> solutions                print all solutions (after the exam!)
#   ./mock.sh <E> cleanup                  remove everything exam E created
#   ./mock.sh <E> <Q>                      reset + set up only question Q, then print it
#   ./mock.sh <E> <Q> question|validate|solution|cleanup
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/lib/common.sh"
usage(){ sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

title(){ sed -n '1s/^# Mock Exam 0[0-9] - //p' "$1/Question.bash"; }

if [ "$1" = "list" ] || [ -z "$1" ]; then
  for X in "$ROOT"/Mock-Exam-*; do
    echo "$(basename "$X")"
    for d in "$X"/Q*; do echo "  $(title "$d")"; done
  done
  [ -z "$1" ] && echo && usage
  exit 0
fi

[[ "$1" =~ ^[0-9]+$ ]] || usage
E=$(printf "%02d" "$((10#$1))"); EX="$ROOT/Mock-Exam-$E"; EN=$((10#$1))
[ -d "$EX" ] || { echo "Mock exam $1 not found. Run ./mock.sh list"; exit 1; }
CLOCK=/root/.cka-lab/mock$EN-clock

qdir(){ ls -d "$EX"/Q"$(printf "%02d" "$((10#$1))")"-* 2>/dev/null | head -1; }
remaining(){
  [ -f "$CLOCK" ] || { echo "Clock not started (./mock.sh $EN start)."; return; }
  read -r S M < "$CLOCK"; local left=$(( S + M*60 - $(date +%s) ))
  if [ $left -le 0 ]; then echo "TIME IS UP ($(( -left / 60 )) min over)."
  else printf "Time left: %d:%02d of %d min\n" $((left/60)) $((left%60)) "$M"; fi
}

if [[ "$2" =~ ^[0-9]+$ ]]; then
  D=$(qdir "$2"); [ -d "$D" ] || { echo "Question $2 not found in mock exam $EN."; exit 1; }
  case "${3:-setup}" in
    setup)    echo "==> Setting up $(basename "$EX")/$(basename "$D") ..."
              bash "$D/LabSetUp.bash" || { echo "Setup reported an error - see above."; exit 1; }
              echo; cat "$D/Question.bash"
              echo; echo "When finished:  ./mock.sh $EN $((10#$2)) validate" ;;
    question) cat "$D/Question.bash" ;;
    validate) bash "$D/validate.sh" ;;
    solution) cat "$D/SolutionNotes.bash" ;;
    cleanup)  bash "$D/cleanup.sh" && echo "Cleanup done." ;;
    *) usage ;;
  esac
  exit
fi

case "${2:-}" in
  start)
    M=${3:-120}; mkdir -p /root/.cka-lab
    echo "==> Setting up Mock Exam $E (this takes a few minutes) ..."
    for d in "$EX"/Q*; do
      if [ -f "$d/ONDEMAND" ]; then echo "  - $(basename "$d"): set up when you reach it: ./mock.sh $EN $((10#$(basename "$d" | cut -c2-3)))"; continue; fi
      echo "  - $(basename "$d")"
      bash "$d/LabSetUp.bash" > "/root/.cka-lab/mock$EN-$(basename "$d").setup.log" 2>&1 \
        || echo "    setup reported an error - see /root/.cka-lab/mock$EN-$(basename "$d").setup.log"
    done
    echo "$(date +%s) $M" > "$CLOCK"
    echo; echo "==> Mock Exam $E started: $M minutes. Answers files go in /root/mock$EN/."
    echo "    ./mock.sh $EN questions   ./mock.sh $EN <Q> question   ./mock.sh $EN time   ./mock.sh $EN score"
    echo; for d in "$EX"/Q*; do cat "$d/Question.bash"; echo; done ;;
  questions) for d in "$EX"/Q*; do cat "$d/Question.bash"; echo; done ;;
  time) remaining ;;
  score)
    remaining; echo
    OK=0; N=0
    for d in "$EX"/Q*; do
      N=$((N+1)); out=$(bash "$d/validate.sh" 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
      res=$(echo "$out" | grep '^Result:' | sed 's/Result: //')
      if echo "$out" | grep -q 'SUCCESS'; then OK=$((OK+1)); printf "  ${GREEN}[PASS]${NC} %s  (%s)\n" "$(title "$d")" "$res"
      else printf "  ${RED}[FAIL]${NC} %s  (%s)\n" "$(title "$d")" "${res:-not checked}"; fi
    done
    PCT=$(( OK * 100 / N ))
    echo; echo "Score: $OK/$N ($PCT%) - passing is 66% (10/15)."
    [ $PCT -ge 66 ] && echo -e "${GREEN}PASSED${NC}" || echo -e "${RED}NOT PASSED${NC}"
    echo "Details for one question: ./mock.sh $EN <Q> validate" ;;
  solutions) for d in "$EX"/Q*; do echo "# ===== $(title "$d")"; cat "$d/SolutionNotes.bash"; echo; done ;;
  cleanup)
    for d in $(ls -d "$EX"/Q* | sort -r); do echo "  - cleaning $(basename "$d")"; bash "$d/cleanup.sh" >/dev/null 2>&1; done
    rm -f "$CLOCK" /root/.cka-lab/mock$EN-*.setup.log; echo "Cleanup done." ;;
  *) usage ;;
esac
