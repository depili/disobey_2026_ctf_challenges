package main

import (
	"archive/zip"
	"bufio"
	"bytes"
	"crypto/sha256"
	_ "embed"
	"fmt"
	"io/ioutil"
	"os"
)

var (
	//go:embed flag.zip
	FlagZip []byte
)

//garble:controlflow block_splits=max junk_jumps=max flatten_passes=max
func main() {
	scanner := bufio.NewScanner(os.Stdin)

	checkChan := make(chan bool, 50)

	fmt.Printf("Enter password: ")

	for scanner.Scan() {
		text := scanner.Text()

		if text == "" {
			os.Exit(0)
		}

		go pwCheck(text, checkChan)

		ok := true

		for b := range checkChan {
			if !b {
				ok = false
			}
		}

		if ok {
			fmt.Printf("\nPassword ok!\n")

			r := bytes.NewReader(FlagZip)
			z, _ := zip.NewReader(r, int64(r.Len()))

			for _, f := range z.File {
				rc, _ := f.Open()
				str, _ := ioutil.ReadAll(rc)
				fmt.Println(str)
			}

			os.Exit(0)
		} else {
			fmt.Printf("\nWrong password, try harder\n")
			os.Exit(0)
		}

		fmt.Printf("\nEnter password: ")
	}
}

/*
	func do_sdl() {
		var err error

		defer binsdl.Load().Unload()

		sdl.SetAppMetadata("rm -fr /", "0.12.1", "com.cobalt_strike")

		sdl.SetHint(sdl.HINT_APP_NAME, "dd if=/dev/urandom of=/dev/sda")

		if err = sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO | sdl.INIT_EVENTS); err != nil {
			log.Fatalf("Failed to clear: %s\n", err)
		}

		title := fmt.Sprintf("Encrypting filesystem...")
		window, renderer, err := sdl.CreateWindowAndRenderer(title, 1024, 1024, sdl.WINDOW_RESIZABLE)
		if err != nil {
			log.Fatalf("Failed encrypt: %v", err)
		}

		defer sdl.Quit()
		defer window.Destroy()
		defer renderer.Destroy()

		err = sdl.HideCursor() // Hide mouse cursor
		check(err)

		err = renderer.Clear()
		check(err)

		log.Printf("Ransomware done\n")

		// Do not exit full screen mode on focus loss in multi-monitor systems
		sdl.SetHint(sdl.HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS, "0")
	}
*/

//garble:controlflow block_splits=max junk_jumps=max flatten_passes=max
func pwCheck(pw string, ch chan bool) {
	h := sha256.Sum256([]byte(pw))
	h_str := fmt.Sprintf("%x", h)

	if h_str == hash {
		ch <- true
	} else {
		ch <- false
	}

	close(ch)
}

//garble:controlflow block_splits=max junk_jumps=max flatten_passes=max
func check(err error) {
	if err != nil {
		panic(err)
	}
}

var pw string

const hash = "204be96a86d6d40f3fb4205c269e418b7cc371fd51709ecbdeb5c546306b2daf"
