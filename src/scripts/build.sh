#!/bin/bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v  -mod=vendor -ldflags="-w -s" -o "$OUTPUT_FILE" "$INPUT_FILE"
