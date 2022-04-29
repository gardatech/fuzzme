package fuzzme

import (
	"fmt"
)

func check_index(data []byte, index int) {
	if data[data[index]] == 3 {
		panic(fmt.Sprintf("data[data[%d]] is 3!", index))
	}
}

func recursive_sum(data []byte, nest_level int) int {
	divisor := len(data)
	if divisor < 1 {
		divisor = 1
	}
	sum := nest_level + int(data[nest_level%divisor])
	if sum < 2 {
		return sum
	}

	sum = sum + recursive_sum(data, nest_level+1)
	return sum
}

func busy_loop(data []byte) int {
	d := make([]byte, len(data))
	copy(d, data)

	sum := 0
	for {
		i := 0
		for i < len(d) {
			sum = sum + int(d[i])
			i++
		}
		if sum > 20 {
			break
		}

		sum = 0
		i = 0
		for i < len(d) {
			d[i]++
			i++
		}
	}
	return sum
}

func Parse(data []byte) int {
	if len(data) < 3 {
		return 0
	}
	sum := recursive_sum(data, 0)
	if sum == 13 {
		return 0
	}
	sum = sum + busy_loop(data)
	if sum < 1 {
		return 0
	}
	check_index(data, 2)
	return 1
}
