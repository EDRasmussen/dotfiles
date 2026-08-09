; extends

; Parse the text surrounding {{ Go template actions }} as HTML.
((text) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined))
