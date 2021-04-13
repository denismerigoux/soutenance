%{
  open Ast
%}

%token <string> NOM
%token PROFESSEUR EXTERNE HOMME FEMME PRESIDENT MID
%token EOF

%start jury_file

%type <professeur list> jury_file

%%

sexe:
| HOMME { Source_loi.Homme () }
| FEMME { Source_loi.Femme () }

jury_line:
| n = NOM MID s = sexe e = option(EXTERNE) prof = option(PROFESSEUR) pres = option(PRESIDENT) {
  {
    nom = n;
    sexe = s;
    professeur = (match prof with Some _ -> true | None -> false);
    externe = (match e with Some _ -> true | None -> false);
    president = (match pres with Some _ -> true | None -> false);
  }
}

jury_file:
| l = jury_line f = jury_file { l::f }
| EOF { [] }