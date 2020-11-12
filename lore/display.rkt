#lang racket

(require "./base.rkt" website-js
	 website-js/components/accordion-cards)

;For display of lore things
;  Note that many of these functions do not take
;  lore structs as input.  Instead they take names
;  of packages that have a lore module.
;  e.g. 'fire-particles
;  From this, it is easy to dynamically require
;  'fire-particles/lore, and/or anything else that
;  might be useful in the 'fire-particles package,
;  (like the rune language, etc.)

(provide rune-collection-name->preview-card 
	 rune-collection-name->preview-icon
	 authored-work-name->preview-image/page 
	 authored-work-name->authored-work-card
	 rune-collection-name->rune-collection/page
	 lore->name-slug

	 authored-work-card
	 download-button
	 coming-soon)

;Useful for creating URLs
(define (lore->name-slug lore)
  (string-replace 
    (string-downcase (cond 
		       [(authored-work-lore? lore)
			(authored-work-lore-name lore)]
		       [(rune-collection-lore? lore)
			(rune-collection-lore-name lore)]))
    " " "-"))

;To standardize links that go to collections
(define (link-to-collection name [content name])
  (a href: 
     ;The path convention on codespells.org
     ;  Can always add a kw param if need something else.
     (~a "/collections/"
	 (string-replace 
	   (string-downcase name)
	   " " "-")
	 "/index.html")
     content))


;Nice to have a card that contains a link to the
;  Rune Collection's fulll page
(define (rune-collection-preview-card name preview)
  (card 
    (card-header
      (link-to-collection name))
    (card-body
      preview)))


;Generate a rune collection preview card from the name
(define (rune-collection-name->preview-card module-name)
  (define module-name/lore (string->symbol
			     (~a module-name "/lore")))

  (define lore 
    (dynamic-require module-name/lore 'lore))

  (rune-collection-preview-card 
    (rune-collection-lore-name lore) 
    (rune-collection-lore-preview-image lore)))


;Sometimes you don't want a full card, just an icon
;  that links to the collection's full page
(define (rune-collection-name->preview-icon module-name)
  (define module-name/lore (string->symbol
			     (~a module-name "/lore")))

  (define lore 
    (dynamic-require module-name/lore 'lore))

  (link-to-collection (rune-collection-lore-name lore) 
		      (rune-collection-lore-preview-image lore)))


;Constructs the full page that you can (render #:to "wherever")
(define (rune-collection-name->rune-collection/page
	  rune-collection-name
	  #:path path
	  #:wrapper[wrapper identity])

  (define lore (dynamic-require-lore rune-collection-name))
  (page (identity path)
	(wrapper
	  (container
	    (h1 (rune-collection-lore-name lore))
	    (rune-collection-lore-description  lore)
	    (map
	      (lambda (r)
		(card (card-header
			(rune-lore-rune r)
			(h3 (rune-lore-name r)))
		      (card-body
			(rune-lore-description r))))
	      (rune-collection-lore-rune-lores lore))))))


;Creates the "page" you can (render #:to "out" ...), 
;  but in this case "page" is the image file (e.g. the png).
;  In `website` "page" just means file.
(define (authored-work-name->preview-image/page authored-work-name #:path path )
  (let ()
    (define lore (dynamic-require-lore authored-work-name))

    (define preview-image
      (authored-work-lore-preview-image lore))
    (page (identity path)  
	  preview-image)))

;A card for an authored work.  Currently,
;  we don't have full pages for authored works.  But 
;  we certainly might in the future, in which case
;  the link to the page would be found here.
(define (authored-work-name->authored-work-card pkg-name )
  (let ()
    (define lore (dynamic-require-lore pkg-name))

    (define name 
      (authored-work-lore-name lore))
    (define description
      (authored-work-lore-description lore))
    (define rune-collections
      (authored-work-lore-rune-collection-names lore))
    (define preview-image
      (authored-work-lore-preview-image lore))

    (authored-work-card 
      #:name (h3 name) 
      #:preview-image (img class: "card-img-top"
		     src: (~a 
			    "works/" (lore->name-slug lore)
			    "/preview.png"))

		(accordion-card #:header "Read More..."
				(h5 "Rune Collections")
				(map rune-collection-name->preview-icon 
				  rune-collections)
				(br)
				description)

		(hr)

		;Change on s3
		(download-button (~a pkg-name)))))


(define (authored-work-card #:name title #:preview-image img . content)
  (card
    (card-header title
		 img)
    (card-body content)))

(define (download-button name)
  (local-require website/bootstrap/font-awesome)
  (a href: (~a "https://codespells-org.s3.amazonaws.com/StandaloneBuilds/" name "/0.0/" name ".zip")
     (button-success "Download for Windows"
		     (fa-windows))))


(define (coming-soon)
  (alert-primary "Coming soon!"))


