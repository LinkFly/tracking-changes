(defpackage :tracking-changes-utils 
  (:use :cl :tracking-changes)  
  (:export #:delete-in-packages-sandbox))

(in-package :tracking-changes-utils)

(defun delete-in-packages-sandbox (sandbox &optional packages)
  (if packages
      (loop for pkg in packages
	 for used-by = (package-used-by-list pkg)
	 when used-by do (delete-in-packages-sandbox sandbox used-by)
	 if (gethash pkg sandbox) do
	 (format t "~%Package ~S deleting ..." pkg)
	 (delete-package pkg)
	 (format t "~%Package ~S deleted" pkg)
	 (remhash pkg sandbox)
	 else do (error "Package miss into sandbox"))
      (progn 
	(loop for pkg being the hash-key in sandbox
	   do (delete-in-packages-sandbox sandbox (list pkg)))
	(clrhash sandbox))))
