(* This file is part of the Catala compiler, a specification language for tax and social benefits
   computation rules. Copyright (C) 2021 Denis Merigoux <denis.merigoux@gmail.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
   in compliance with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software distributed under the License
   is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
   or implied. See the License for the specific language governing permissions and limitations under
   the License. *)

%{
  open Ast
%}

%token <string> NOM
%token PROFESSEUR EXTERNE HOMME FEMME PRESIDENT START COLON CANDIDATS
%token EOF

%start jury_file

%type <membre_jury list> jury_file

%%

sexe:
| HOMME { Source_loi.Homme () }
| FEMME { Source_loi.Femme () }

jury_attribute:
| EXTERNE { Externe }
| PROFESSEUR { Professeur }
| PRESIDENT { President }
| s = sexe { Sexe s }

jury_line:
| START n = NOM COLON attrs = list(jury_attribute)  {
  {
    nom = n;
    attributs = attrs;
  }
}

jury_file:
| l = jury_line f = jury_file { l::f }
| CANDIDATS { [] }
| EOF { [] }