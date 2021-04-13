(* This file is part of the Catala compiler, a specification language for tax and social benefits
   computation rules. Copyright (C) 2021 Denis Merigoux <denis.merigoux@gmail.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
   in compliance with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software distributed under the License
   is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
   or implied. See the License for the specific language governing permissions and limitations under
   the License. *)

open Cmdliner

let file =
  Arg.(required & pos 0 (some file) None & info [] ~docv:"FILE" ~doc:"File describing the defense")

let parite_minimale =
  Arg.(
    value
    & opt (some float) None
    & info [ "p"; "minimal_parity" ] ~docv:"MIN_PARITY"
        ~doc:
          "Minimal ratio of men or women in the comittee below which there is inbalance (default \
           0.25)")

let impossible_rapporteurs_externes =
  Arg.(
    value & flag
    & info
        [ "impossible_external_referees"; "O" ]
        ~doc:"Use this option if it was impossible to find external referees for your committee")

let version = "1.0.0"

let info =
  let doc = "Checking if a French PhD defense fulfills legal obligations." in
  let man =
    [
      `S Manpage.s_authors;
      `P "Denis Merigoux <denis.merigoux@gmail.com>";
      `S Manpage.s_examples;
      `P "Typical usage:";
      `Pre "soutenance fichier.md";
      `S Manpage.s_bugs;
      `P "Please file bug reports at https://github.com/denismerigoux/soutenance/issues";
    ]
  in
  let exits = Term.default_exits @ [ Term.exit_info ~doc:"on error." (-1) ] in
  Term.info "soutenance" ~version ~doc ~exits ~man

let soutenance_t f = Term.(const f $ impossible_rapporteurs_externes $ parite_minimale $ file)

exception Error of string * Ast.position option

let raise_error (s : string) : 'a = raise (Error (s, None))

let raise_spanned_error (s : string) (pos : Ast.position) = raise (Error (s, Some pos))

let print_with_style (styles : ANSITerminal.style list) (str : ('a, unit, string) format) =
  ANSITerminal.sprintf styles str

(** Prints [\[DEBUG\]] in purple on the terminal standard output *)
let debug_marker () = print_with_style [ ANSITerminal.Bold; ANSITerminal.magenta ] "[DEBUG] "

(** Prints [\[ERROR\]] in red on the terminal error output *)
let error_marker () = print_with_style [ ANSITerminal.Bold; ANSITerminal.red ] "[ERREUR] "

(** Prints [\[WARNING\]] in yellow on the terminal standard output *)
let warning_marker () = print_with_style [ ANSITerminal.Bold; ANSITerminal.yellow ] "[ATTENTION] "

(** Prints [\[RESULT\]] in green on the terminal standard output *)
let result_marker () = print_with_style [ ANSITerminal.Bold; ANSITerminal.green ] "[RÉSULTAT] "

(** Prints [\[LOG\]] in red on the terminal error output *)
let log_marker () = print_with_style [ ANSITerminal.Bold; ANSITerminal.black ] "[LOG] "

let concat_with_line_depending_prefix_and_suffix (prefix : int -> string) (suffix : int -> string)
    (ss : string list) =
  match ss with
  | hd :: rest ->
      let out, _ =
        List.fold_left
          (fun (acc, i) s ->
            ((acc ^ prefix i ^ s ^ if i = List.length ss - 1 then "" else suffix i), i + 1))
          ((prefix 0 ^ hd ^ if 0 = List.length ss - 1 then "" else suffix 0), 1)
          rest
      in
      out
  | [] -> prefix 0

(** The int argument of the prefix corresponds to the line number, starting at 0 *)
let add_prefix_to_each_line (s : string) (prefix : int -> string) =
  concat_with_line_depending_prefix_and_suffix
    (fun i -> prefix i)
    (fun _ -> "\n")
    (String.split_on_char '\n' s)

let debug_print (s : string) =
  Printf.printf "%s\n" (add_prefix_to_each_line s (fun _ -> debug_marker ()));
  flush stdout;
  flush stdout

let error_print (s : string) =
  Printf.eprintf "%s\n" (add_prefix_to_each_line s (fun _ -> error_marker ()));
  flush stderr;
  flush stderr

let warning_print (s : string) =
  Printf.printf "%s\n" (add_prefix_to_each_line s (fun _ -> warning_marker ()));
  flush stdout;
  flush stdout

let result_print (s : string) =
  Printf.printf "%s\n" (add_prefix_to_each_line s (fun _ -> result_marker ()));
  flush stdout;
  flush stdout

let log_print (s : string) =
  Printf.printf "%s\n" (add_prefix_to_each_line s (fun _ -> log_marker ()));
  flush stdout;
  flush stdout
