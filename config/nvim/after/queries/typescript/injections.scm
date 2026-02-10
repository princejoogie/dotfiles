; extends

;; Inject markdown into template strings with /* md */ or /* markdown */ comment
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*(md|markdown)\\s*\\*/")
 (#set! injection.language "markdown"))

;; Markdown injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*(md|markdown)\\s*\\*/")
 (#set! injection.language "markdown")
 (#set! injection.include-children))

;; SQL injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*sql\\s*\\*/")
 (#set! injection.language "sql"))

;; SQL injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*sql\\s*\\*/")
 (#set! injection.language "sql")
 (#set! injection.include-children))

;; HTML injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*html\\s*\\*/")
 (#set! injection.language "html"))

;; HTML injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*html\\s*\\*/")
 (#set! injection.language "html")
 (#set! injection.include-children))

;; CSS injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*css\\s*\\*/")
 (#set! injection.language "css"))

;; CSS injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*css\\s*\\*/")
 (#set! injection.language "css")
 (#set! injection.include-children))

;; GraphQL injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*(gql|graphql)\\s*\\*/")
 (#set! injection.language "graphql"))

;; GraphQL injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*(gql|graphql)\\s*\\*/")
 (#set! injection.language "graphql")
 (#set! injection.include-children))

;; JSON injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*json\\s*\\*/")
 (#set! injection.language "json"))

;; JSON injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*json\\s*\\*/")
 (#set! injection.language "json")
 (#set! injection.include-children))

;; YAML injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*(yaml|yml)\\s*\\*/")
 (#set! injection.language "yaml"))

;; YAML injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*(yaml|yml)\\s*\\*/")
 (#set! injection.language "yaml")
 (#set! injection.include-children))

;; Bash/Shell injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*(bash|sh|shell)\\s*\\*/")
 (#set! injection.language "bash"))

;; Bash/Shell injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*(bash|sh|shell)\\s*\\*/")
 (#set! injection.language "bash")
 (#set! injection.include-children))

;; Python injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*(python|py)\\s*\\*/")
 (#set! injection.language "python"))

;; Python injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*(python|py)\\s*\\*/")
 (#set! injection.language "python")
 (#set! injection.include-children))

;; Regex injection
((comment) @_lang
 .
 (template_string
   (string_fragment) @injection.content)
 (#match? @_lang "/\\*\\s*(regex|regexp)\\s*\\*/")
 (#set! injection.language "regex"))

;; Regex injection for template strings with substitutions
((comment) @_lang
 .
 (template_string) @injection.content
 (#match? @_lang "/\\*\\s*(regex|regexp)\\s*\\*/")
 (#set! injection.language "regex")
 (#set! injection.include-children))
