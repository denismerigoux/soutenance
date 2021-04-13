(lang dune 2.8)

(name soutenance)
(version 1.0.0)
(generate_opam_files true)
(formatting)

(source (uri git+https://github.com/denismerigoux/soutenance.git))
(homepage https://github.com/denismerigoux/soutenance)
(bug_reports https://github.com/denismerigoux/soutenance/issues)
(authors "Denis Merigoux")
(maintainers "denis.merigoux@gmail.com")
(license Apache-2.0)



(package
 (name soutenance)
 (synopsis "Compose your PhD defence committee in accordance with French law")
 (depends
   (menhir (>= 20200211))
 )
)
(using menhir 2.1)
