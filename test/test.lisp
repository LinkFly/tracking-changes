;;; Test
(require :asdf)
(push (make-pathname :defaults *load-pathname* 
		     :directory (butlast (pathname-directory *load-pathname*))
		     :name nil
		     :type nil)
      asdf:*central-registry*)
(asdf:load-system :tracking-changes)

(defpackage :test-tracking-changes
  (:use :cl :tracking-changes :tracking-changes-utils)
  (:export #:run-test))

(in-package :test-tracking-changes)

(defparameter *test-file* "test-packages.lisp")

(defun test-tracking-changes (&aux compiled-file res)
  (with-monitoring *test-file*
    (setf compiled-file (compile-file *test-file*)))
  (setq res
	(and 
	 (equal 
	  (list (find-package :pkg1) (find-package :pkg2)) 
	  (get-sandbox-packages-list *test-file*))
	 (equal '(nil nil)
		(progn
		  (delete-in-packages-sandbox
		   (get-sandbox-packages *test-file*))
		  (list (find-package :pkg1) (find-package :pkg2))))))
  (delete-file compiled-file)
  res)

(defun run-test (&aux res)
  (format t (if (setf res (test-tracking-changes))
		"~&Test passed~%"
		"~&Test failed~%"))
  res)
