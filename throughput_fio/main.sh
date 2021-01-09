#!/bin/bash
types=(read write)
targets=(vanila ort)
nums=(1 10 30 50 100)
pattern="aggrb=([0-9]+)KB"
for type in "${types[@]}"; do
    echo $type
    for num in "${nums[@]}"; do
        printf "%s\t" "$num"
        for target in "${targets[@]}"; do
            file="data/${target}/${type}/${num}.log"
            if [[ -f "${file}" ]]; then
                res=$(grep "aggrb=" "${file}")
                if [[ "$res" =~ $pattern ]]; then
                    printf "${BASH_REMATCH[1]}\t"
                else
                    exit 1
                fi
            fi
        done
        echo
    done
done
