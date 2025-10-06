#!/usr/bin/bash

calc() {
    bc -l <<< "$1"
}

derivate() { # f, x
    local dx=0.001
    local fx=$($1 $2)
    local fxh=$($1 $(calc "$2 + $dx"))
    local df=$(calc "$fxh - $fx")
    calc "$df / $dx"
}

# curry() { # f, ...
#     # echo "$1 $2"
#     local out="$1"
#     shift
#     while [ $# -gt 0 ]; do
#         out="$out $1"
#         shift
#     done
#     echo "$out"
# }

# curry() {
#     local out="$1"
#     shift
#     while [ $# -gt 0 ]; do
#         out="$out $1"
#         shift
#     done
#     echo 'λ() ( '"$out"' $@; ); λ'
# }

curry() {
    local out="$1(){"
    while [ $# -gt 0 ]; do
        shift
        out="$out $1"
    done
    eval "$out"' $@; }'
}

sqr() {
    # echo $(($1*$1))
    bc <<< "$1 * $1"
}

add() {
    echo "$(($1 + $2))"
}

integral() { # dx, f, a, b
    local dx=$1
    local f=$2
    local a=$3
    local b=$4
    if (( $(calc "$a > $b") )); then
        calc "-($(integral $dx $f $b $a))"
        return 0
    fi
    local sum=0
    for i in $(seq $a $dx $b); do
        sum=$(calc "$sum + $dx * $($f $i)")
    done
    echo "$sum"
}

integrate() { # dx, f, x
    local dx=$1
    local f=$2
    local x=$3
    integral $dx $f 0 $x
}

newton() { # eps, f, start
    local eps=$1
    local f=$2
    local x=$3
    local fx=$(eval $f $x)
    while (( $(calc "${fx#-} >= $eps") )); do
        local fxh=$(eval $f $(calc "$x + ($eps)"))
        x=$(calc "$x - (($eps) * ($fx)) / (($fxh) - ($fx))")
        fx=$(eval $f $x)
    done
    echo "$x"
}

call() {
    eval $1 $2
}

inverse() ( # eps, f, x
    local eps=$1
    local f=$2
    local x=$3
    eval 'g() { calc "($(eval '"$f"' $1)) - '"$x"'"; }'
    newton $eps g $x
)

# sqrt=$(curry inverse "0.0001" sqr)
# echo "(x^2)^-1 = $sqrt"
# eval $sqrt 169

curry dsqr derivate sqr
curry f derivate dsqr
# x2() { calc "$1 * 2"; }
# curry f derivate x2
for i in $(seq 1 32); do
    echo "f($i) = $(f $i)"
done
