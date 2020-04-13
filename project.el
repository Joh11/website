(require 'ox-publish)

(setq org-publish-project-alist
      '(("org-notes"
	 :base-directory "org/"
	 :base-extension "org"
	 :publishing-directory "docs/"
	 :recursive t
	 :publishing-function org-html-publish-to-html

	 ;; All the style stuff here
	 :html-head "<link rel=\"stylesheet\" href=\"css/style.css\" type=\"text/css\"/>"
	 :with-toc nil
	 :section-numbers nil
	 :html-postamble nil)

	("org-static"
	 :base-directory "org/"
	 :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
	 :publishing-directory "docs/"
	 :recursive t
	 :publishing-function org-publish-attachment)

	("org" :components ("org-notes" "org-static"))))
