(require 'ox-publish)

;; Utility function
(defun joh/get-string-from-file (path)
  "Return PATH's file content as string."
  (with-temp-buffer
    (insert-file-contents path)
    (buffer-string)))

(defun joh/export-block (export-block contents info)
  "If the export block type is gpx, then put the html block
inside a script tag, and insert below a map"
  (if (string= (org-element-property :type export-block) "GPX")
      (format (joh/get-string-from-file "templates/map.html")
	      (org-remove-indentation (org-element-property :value export-block)))
    ;; If not gpx then delegate to the default html export
    (org-html-export-block export-block contents info)))

(org-export-define-derived-backend 'joh/html 'html
  :translate-alist '((export-block . joh/export-block)))

(defun joh/publish-to-html (plist filename pub-dir)
  "Modified version of org-html-publish-to-html. "
  (org-publish-org-to 'joh/html filename
		      (concat "." (or (plist-get plist :html-extension)
				      org-html-extension
				      "html"))
		      plist pub-dir))

(setq joh/website/base-dir (concat default-directory "org/"))
(setq joh/website/publish-dir (concat default-directory "public_html")) ;; TODO fix the absolute path stuff 
(setq joh/website/template-dir (concat default-directory "org/templates/"))

(setq org-publish-project-alist
      `(("org-notes"
	 :base-directory ,joh/website/base-dir
	 :base-extension "org"
	 :publishing-directory ,joh/website/publish-dir
	 :recursive t
	 :publishing-function joh/publish-to-html

	 ;; All the style stuff here
	 :html-doctype "html5"
	 
	 :html-head ,(joh/get-string-from-file (concat joh/website/template-dir "head.html"))

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
