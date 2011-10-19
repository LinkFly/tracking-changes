#!/bin/sh

sbcl --noinform --load test.lisp --eval "(progn (test-tracking-changes:run-test) (quit))"