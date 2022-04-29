// +build gofuzz

package fuzzme

func Fuzz(data []byte) int {
	return Parse(data)
}
