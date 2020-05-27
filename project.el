(require 'ox-publish)
(require 'cl)

(unless (package-installed-p 'htmlize)
    (package-refresh-contents)
    (package-install 'htmlize))

(setq make-backup-files nil)

;; Utility function
(defun joh/get-string-from-file (path)
  "Return PATH's file content as string."
  (with-temp-buffer
    (insert-file-contents path)
    (buffer-string)))

(setq joh/website/base-dir (concat default-directory "org/"))
(setq joh/website/static-dir (concat default-directory "static/"))
(setq joh/website/publish-dir (concat default-directory "public_html/")) ;; TODO fix the absolute path stuff 
(setq joh/website/template-dir (concat default-directory "templates/"))


(defun joh/export-block (export-block contents info)
  "If the export block type is gpx, then put the html block
inside a script tag, and insert below a map"
  (if (string= (org-element-property :type export-block) "GPX")
      (format (joh/get-string-from-file (concat joh/website/template-dir "map.html"))
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

;; Resolve the subdirectory broken links problem
(setq *joh/publish-draft-p* nil)

(defun joh/level-to-path (level)
  "Return the right number of .. for the given LEVEL"
  (if (= level 0)
      ""
    (concat "../" (joh/level-to-path (- level 1)))))

(defun joh/count-occurences (string char)
  "Count the number of occurences of CHAR in the given STRING. "
  (loop for c across string when (equal c char) sum 1))

(defun joh/org-pages-subproject (dirname &rest extra-options)
  "Return the right project alist to make a subproject of
org-pages. 

DIRNAME must end with a slash, unless it represents
the main directory ; it must then be an empty string. "
  (let* ((level (joh/count-occurences dirname ?/))
	 (prefix (joh/level-to-path level))
	 (pretty-name (if (= 0 (length dirname))
			  "org-pages"
			(concat "org-pages-" (substring dirname 0 -1)))))
    `(,pretty-name
       :base-directory ,(concat joh/website/base-dir dirname)
       :base-extension "org"
       ,@(if *joh/publish-draft-p* nil '(:exclude "^_"))
       :publishing-directory ,(concat joh/website/publish-dir dirname)
       :publishing-function joh/publish-to-html

       :html-doctype "html5"

       :html-head ,(format (joh/get-string-from-file (concat joh/website/template-dir "head.html"))
			   prefix)

       :html-preamble ,(format (joh/get-string-from-file (concat joh/website/template-dir "preamble.html"))
			       prefix prefix prefix prefix)
       :html-postamble ,(joh/get-string-from-file (concat joh/website/template-dir "postamble.html"))
       
       :with-toc nil
       :section-numbers nil

       ,@extra-options)))

(setq org-publish-project-alist
      `(,(joh/org-pages-subproject "")
	,(joh/org-pages-subproject "blog/"
				   :auto-sitemap t
				   :sitemap-title "All posts"
				   :sitemap-filename "posts.org")

	("org-static"
	 :base-directory ,joh/website/static-dir
	 :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
	 :publishing-directory ,joh/website/publish-dir
	 :recursive t
	 :publishing-function org-publish-attachment)))
