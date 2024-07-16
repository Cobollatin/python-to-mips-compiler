#!/usr/bin/env bash
./build.sh
echo ========================================
echo Running the tests
echo ========================================
rm -f tests/*.asm
passed=0
total=0
passet_tests=()
failed_tests=()
for file in tests/*.py; do
    should=$(echo """$file""" | cut -d'/' -f2 | cut -d'_' -f1)
    total=$((total + 1))
    echo Running test """$file"""...
    ./compiler """$file""" """$file""".asm
    if [ $? -ne 0 ]; then
        # We check if should is FAIL
        if [ """$should""" == "FAIL" ]; then
            passed=$((passed + 1))
            passet_tests+=("""$file""")
        else
            failed_tests+=("""$file""")
        fi
        continue
    fi
    if [ """$should""" == "PASS" ]; then
        passed=$((passed + 1))
        passet_tests+=("""$file""")
    else
        failed_tests+=("""$file""")
    fi
done

echo ========================================
echo $passed out of $total tests passed
echo ========================================
echo Passed tests:
for test in "${passet_tests[@]}"; do
    echo """$test"""
done
echo ========================================
echo Failed tests:
for test in "${failed_tests[@]}"; do
    echo """$test"""
done
echo ========================================
