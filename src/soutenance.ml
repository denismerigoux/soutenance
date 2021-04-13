(* This file is part of the Catala compiler, a specification language for tax and social benefits
   computation rules. Copyright (C) 2021 Denis Merigoux <denis.merigoux@gmail.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
   in compliance with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software distributed under the License
   is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
   or implied. See the License for the specific language governing permissions and limitations under
   the License. *)

let provider lexbuf () =
  let tok = Lexer.lex_jury lexbuf in
  let start, stop = Sedlexing.lexing_positions lexbuf in
  (tok, start, stop)

let id_gen = ref 0

let fresh_id () =
  let out = !id_gen in
  incr id_gen;
  out

let membre_jury_ast_to_source (m : Ast.membre_jury) : Source_loi.membre_du_jury =
  {
    id = Runtime.integer_of_int (fresh_id ());
    professeur = List.exists (fun attr -> attr = Ast.Professeur) m.attributs;
    president = List.exists (fun attr -> attr = Ast.President) m.attributs;
    externe = List.exists (fun attr -> attr = Ast.Externe) m.attributs;
    rapporteur = List.exists (fun attr -> attr = Ast.Rapporteur) m.attributs;
    habilitation_a_diriger_recherches =
      List.exists (fun attr -> attr = Ast.Habilitation) m.attributs;
    directeur_de_these = List.exists (fun attr -> attr = Ast.Directeur) m.attributs;
    hors_monde_universitaire = List.exists (fun attr -> attr = Ast.NonUniversitaire) m.attributs;
    sexe =
      (match
         List.fold_left
           (fun acc attr -> match attr with Ast.Sexe s -> Some s | _ -> acc)
           None m.attributs
       with
      | Some s -> s
      | None -> Cli.raise_error (Format.asprintf "Sexe inconnu pour le membre du jury: %s" m.nom));
  }

let driver (impossible_rapporteurs_externes : bool) (parite_minimale : float option) (file : string)
    : int =
  try
    let oc = try open_in file with Sys_error msg -> Cli.raise_error msg in
    let lexbuf = Sedlexing.Utf8.from_channel oc in
    Sedlexing.set_filename lexbuf file;
    let ast =
      try MenhirLib.Convert.Simplified.traditional2revised Parser.jury_file (provider lexbuf)
      with Parser.Error ->
        Cli.raise_spanned_error "Erreur de syntaxe" (Sedlexing.lexing_positions lexbuf)
    in
    close_in oc;
    let members = List.map membre_jury_ast_to_source ast in
    if List.length (List.filter (fun m -> m.Source_loi.president) members) <> 1 then begin
      Cli.error_print "Le jury de thèse doit avoir exactement une ou un président";
      exit (-1)
    end;
    let parite_minimale = match parite_minimale with Some p -> p | None -> 0.25 in
    let ratio_hommes_femmes =
      float_of_int
        (List.fold_left
           (fun acc m -> match m.Source_loi.sexe with Source_loi.Femme _ -> acc + 1 | _ -> acc)
           0 members)
      /. float_of_int (List.length members)
    in
    let ratio_externes =
      float_of_int (List.length (List.filter (fun m -> m.Source_loi.externe) members))
      /. float_of_int (List.length members)
    in
    let ratio_professeurs =
      float_of_int (List.length (List.filter (fun m -> m.Source_loi.professeur) members))
      /. float_of_int (List.length members)
    in
    let out =
      Source_loi.validation_jury
        {
          Source_loi.membres_in = (fun _ -> Array.of_list members);
          Source_loi.parite_minimale_representation_equilibree_in =
            (fun _ -> Runtime.decimal_of_float parite_minimale);
          Source_loi.impossible_trouver_rapporteurs_externes_in =
            (fun _ -> impossible_rapporteurs_externes);
          Source_loi.nombre_membres_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.parite_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.president_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.ratio_femmes_hommes_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.externes_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.professeurs_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.directeurs_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.rapporteurs_nombre_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.rapporteurs_externes_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.tout_ok_in = (fun _ -> raise Runtime.EmptyError);
          Source_loi.codirection_hors_universitaire_in = (fun _ -> raise Runtime.EmptyError);
        }
    in
    if out.Source_loi.tout_ok_out then begin
      Cli.result_print "La soutenance respecte toutes les obligations légales";
      if ratio_hommes_femmes <> 0.5 then
        Cli.warning_print
          (Format.asprintf "Un peu de déséquilibre entre femmes et hommes (%.0f%% de femmes)"
             (ratio_hommes_femmes *. 100.));
      0
    end
    else begin
      Cli.error_print "Certaines obligations légales ne sont pas respectées!";
      if not out.Source_loi.nombre_membres_ok_out then
        Cli.error_print
          (Format.asprintf
             "Le nombre de membres du jury de thèse est trop petit ou trop grand (%d pour \
              l'instant, doit être entre 4 et 8)"
             (List.length members));
      if not out.Source_loi.parite_ok_out then
        Cli.error_print
          (Format.asprintf
             "Trop de déséquilibre entre femmes et hommes dans le jury de thèse (%.0f%% de \
              femmes)"
             (ratio_hommes_femmes *. 100.));
      if not out.Source_loi.professeurs_ok_out then
        Cli.error_print
          (Format.asprintf
             "Pas assez de professeurs ou directeurs de recherche dans le jury de thèse \
              (seulement %.0f%%)"
             (ratio_professeurs *. 100.));
      if not out.Source_loi.externes_ok_out then
        Cli.error_print
          (Format.asprintf "Pas assez de membres externes du jury de thèse (seulement %.0f%%)"
             (ratio_externes *. 100.));
      if not out.Source_loi.president_ok_out then
        Cli.error_print "Le jury de thèse doit être présidé par un professeur";
      if not out.Source_loi.directeurs_ok_out then
        Cli.error_print
          "Les directeurs de thèse doivent être habilités à diriger les recherches, et être \
           entre un et deux sauf si un troisième ne vient pas du monde universitaire";
      if not out.Source_loi.rapporteurs_nombre_ok_out then
        Cli.error_print
          "Les rapporteurs de thèse doivent être habilités à diriger les recherche, et être \
           au nombre de deux sauf si un troisième ne vient pas du monde universitaire";
      if not out.Source_loi.rapporteurs_externes_ok_out then
        Cli.error_print "Sauf impossibilité, les rapporteurs doivent être externes";
      -1
    end
  with Cli.Error (msg, pos) ->
    Cli.error_print
      (Format.asprintf "%s%s"
         (match pos with None -> "" | Some pos -> Ast.position_to_string pos ^ " : ")
         msg);
    -1

let _ =
  let return_code = Cmdliner.Term.eval (Cli.soutenance_t driver, Cli.info) in
  match return_code with
  | `Ok 0 -> Cmdliner.Term.exit (`Ok 0)
  | _ -> Cmdliner.Term.exit (`Error `Term)
