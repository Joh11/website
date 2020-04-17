(require 'ox-publish)

;; Utility function
(defun joh/get-string-from-file (path)
  "Return PATH's file content as string."
  (with-temp-buffer
    (insert-file-contents path)
    (buffer-string)))

(setq joh/website/base-dir (concat default-directory "org/"))
(setq joh/website/publish-dir default-directory) ;; TODO fix the absolute path stuff 
(setq joh/website/template-dir (concat default-directory "org/templates/"))

(setq org-publish-project-alist
      `(("org-notes"
	 :base-directory ,joh/website/base-dir
	 :base-extension "org"
	 :publishing-directory ,joh/website/publish-dir
	 :recursive t
	 :publishing-function org-html-publish-to-html

	 ;; All the style stuff here
	 :html-doctype "html5"
	 
	 :html-head "<link rel=\"stylesheet\" href=\"css/style.css\" type=\"text/css\"/>"

	 :html-preamble ,(joh/get-string-from-file (concat joh/website/template-dir "preamble.html"))
	 :html-postamble ,(joh/get-string-from-file (concat joh/website/template-dir "postamble.html"))
	 
	 :with-toc nil
	 :section-numbers nil)

	("org-static"
	 :base-directory ,joh/website/base-dir
	 :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
	 :publishing-directory ,joh/website/publish-dir
	 :recursive t
	 :publishing-function org-publish-attachment)

	("org" :components ("org-notes" "org-static"))))
