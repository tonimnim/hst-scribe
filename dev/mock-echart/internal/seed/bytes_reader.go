package seed

import (
	"bytes"
	"io"
)

// bytesReader returns an io.Reader over b. Tiny helper to keep the
// json.NewDecoder call site readable without dragging bytes.NewReader
// into the import block of every file that calls LoadPatients.
func bytesReader(b []byte) io.Reader { return bytes.NewReader(b) }
