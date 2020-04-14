(require 'ox-publish)

(setq joh/website/base-dir (concat default-directory "org/"))
(setq joh/website/publish-dir default-directory)

(setq org-publish-project-alist
      `(("org-notes"
	 :base-directory ,joh/website/base-dir
	 :base-extension "org"
	 :publishing-directory ,joh/website/publish-dir
	 :recursive t
	 :publishing-function org-html-publish-to-html

	 ;; All the style stuff here
	 :html-head ,(format "<link rel=\"stylesheet\" href=\"%scss/style.css\" type=\"text/css\"/>" joh/website/base-dir)
	 :with-toc nil
	 :section-numbers nil
	 :html-postamble nil)

	("org-static"
	 :base-directory ,joh/website/base-dir
	 :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
	 :publishing-directory ,joh/website/publish-dir
	 :recursive t
	 :publishing-function org-publish-attachment)

	("org" :components ("org-notes" "org-static"))))
