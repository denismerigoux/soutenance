(* This file is part of the Catala compiler, a specification language for tax and social benefits
   computation rules. Copyright (C) 2021 Denis Merigoux <denis.merigoux@gmail.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
   in compliance with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software distributed under the License
   is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
   or implied. See the License for the specific language governing permissions and limitations under
   the License. *)

type position = Lexing.position * Lexing.position

let position_to_string (pos : position) : string =
  let s, e = pos in
  Printf.sprintf "Dans le fichier %s, de %d:%d à %d:%d" s.Lexing.pos_fname s.Lexing.pos_lnum
    (s.Lexing.pos_cnum - s.Lexing.pos_bol + 1)
    e.Lexing.pos_lnum
    (e.Lexing.pos_cnum - e.Lexing.pos_bol + 1)

type attribut_jury =
  | Professeur
  | Externe
  | Sexe of Source_loi.sexe
  | President
  | Directeur
  | Rapporteur
  | Habilitation
  | NonUniversitaire

type membre_jury = { nom : string; attributs : attribut_jury list }
