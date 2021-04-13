(* This file is part of the Catala compiler, a specification language for tax and social benefits
   computation rules. Copyright (C) 2021 Denis Merigoux <denis.merigoux@gmail.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
   in compliance with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software distributed under the License
   is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
   or implied. See the License for the specific language governing permissions and limitations under
   the License. *)

open Parser
open Sedlexing

let rec lex_jury (lexbuf : lexbuf) : token =
  match%sedlex lexbuf with
  | white_space -> lex_jury lexbuf
  | Plus '#', Plus (Compl '\n'), '\n' -> lex_jury lexbuf
  | '/', '/', Plus (Compl '\n'), '\n' -> lex_jury lexbuf (* one line of comments *)
  | '-' -> START
  | "Hors du jury :" -> CANDIDATS
  | "homme" -> HOMME
  | "femme" -> FEMME
  | "professeur", Opt 'e' -> PROFESSEUR
  | "pr", 0xE9, "sident", Opt 'e' -> PRESIDENT
  | "externe" -> EXTERNE
  | '*', '*', Plus (Compl '*'), '*', '*' ->
      NOM (String.sub (Utf8.lexeme lexbuf) 2 (String.length (Utf8.lexeme lexbuf) - 4))
  | ':' -> COLON
  | eof -> EOF
  | _ -> Cli.raise_spanned_error "Lexer error" (lexing_positions lexbuf)
