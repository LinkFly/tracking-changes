;;; Proof of concept: monitoring changes in the Lisp system after loading the code

(defpackage :tracking-changes 
  (:use :cl)
  (:export #:with-monitoring
	   #:*changes-sandbox*
	   #:get-sandbox-packages
	   #:get-sandbox-packages-list))

(in-package :tracking-changes)

(defparameter *changes-sandbox* (make-hash-table :test 'equal))

(defmacro with-bind-new-packages ((s-new-packages) code &body body)
  (let ((s-old-all-packages (gentemp "OLD-ALL-PACKAGES-")))
    `(let ((,s-old-all-packages (list-all-packages))
	   (,s-new-packages nil))
       ,code
       (setf ,s-new-packages 
	     (set-difference (list-all-packages) 
			     ,s-old-all-packages))
       ,@body)))

(defmacro with-packages-observing (sandbox &body body)
  (let ((s-result (gentemp "RESULT-")))
    `(let (,s-result)
       (with-bind-new-packages (new-packages)
	   (setf ,s-result (multiple-value-list ,@body))
	 (loop for pkg in new-packages
	    do (setf (gethash pkg ,sandbox) t)))
       (apply #'values ,s-result))))

(defmacro with-monitoring (key &body body)
  (let ((s-sandbox (gentemp "SANDBOX-"))
	(s-packages-sandbox (gentemp "PACKAGES-SANDBOX-"))
    	(s-result (gentemp "RESULT-")))
    `(symbol-macrolet ((,s-sandbox (gethash ,key *changes-sandbox*)))
       (let ((,s-packages-sandbox (make-hash-table))
	     (,s-result nil))
	 (with-packages-observing ,s-packages-sandbox 
	   (progn
	     (setf ,s-result (multiple-value-list ,@body))
	     (setf (getf ,s-sandbox :packages) ,s-packages-sandbox)))
	 (apply #'values ,s-result)))))

(defun packages-in-file (key &aux packages-hash)
  (setf packages-hash (getf (gethash key *changes-sandbox*)
			    :packages))
  (when packages-hash 
    (loop for pkg being the hash-key in packages-hash
       collect pkg)))

(defun get-sandbox-packages (key)
  (getf (gethash key *changes-sandbox*) :packages))

(defun get-sandbox-packages-list (key &aux sandbox-packages) 
  (setf sandbox-packages (get-sandbox-packages key))
  (when sandbox-packages
    (loop for pkg being the hash-key in sandbox-packages
       collect pkg)))


