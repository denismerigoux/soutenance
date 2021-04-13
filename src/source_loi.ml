(** This file has been generated by the Catala compiler, do not edit! *)

open Runtime

[@@@ocaml.warning "-26-27"]

type sexe = Femme of unit | Homme of unit

type membre_du_jury = {
  id : integer;
  professeur : bool;
  sexe : sexe;
  president : bool;
  externe : bool;
}

type validation_jury_out = {
  membres_out : membre_du_jury array;
  parite_minimale_representation_equilibree_out : decimal;
  nombre_membres_ok_out : bool;
  parite_ok_out : bool;
  professeurs_ok_out : bool;
  president_ok_out : bool;
  externes_ok_out : bool;
}

type validation_jury_in = {
  membres_in : unit -> membre_du_jury array;
  parite_minimale_representation_equilibree_in : unit -> decimal;
  nombre_membres_ok_in : unit -> bool;
  parite_ok_in : unit -> bool;
  professeurs_ok_in : unit -> bool;
  president_ok_in : unit -> bool;
  externes_ok_in : unit -> bool;
}

let validation_jury (validation_jury_in : validation_jury_in) =
  let membres_ : unit -> membre_du_jury array = validation_jury_in.membres_in in
  let parite_minimale_representation_equilibree_ : unit -> decimal =
    validation_jury_in.parite_minimale_representation_equilibree_in
  in
  let nombre_membres_ok_ : unit -> bool = validation_jury_in.nombre_membres_ok_in in
  let parite_ok_ : unit -> bool = validation_jury_in.parite_ok_in in
  let professeurs_ok_ : unit -> bool = validation_jury_in.professeurs_ok_in in
  let president_ok_ : unit -> bool = validation_jury_in.president_ok_in in
  let externes_ok_ : unit -> bool = validation_jury_in.externes_ok_in in
  let membres_ : membre_du_jury array =
    try membres_ () with EmptyError -> raise NoValueProvided
  in
  let parite_minimale_representation_equilibree_ : decimal =
    try parite_minimale_representation_equilibree_ () with EmptyError -> raise NoValueProvided
  in
  let parite_ok_ : bool =
    try try parite_ok_ () with EmptyError -> false with EmptyError -> raise NoValueProvided
  in
  let professeurs_ok_ : bool =
    try try professeurs_ok_ () with EmptyError -> false with EmptyError -> raise NoValueProvided
  in
  let president_ok_ : bool =
    try
      try president_ok_ ()
      with EmptyError -> (
        try
          if
            Array.fold_left
              (fun (acc_ : integer) (membre_ : _) ->
                if membre_.president then acc_ +! integer_of_string "1" else acc_)
              (integer_of_string "0") membres_
            = integer_of_string "1"
            && Array.fold_left
                 (fun (acc_ : bool) (membre_ : _) -> acc_ && membre_.professeur)
                 true
                 (array_filter (fun (membre_ : _) -> membre_.president) membres_)
          then true
          else raise EmptyError
        with EmptyError -> false)
    with EmptyError -> raise NoValueProvided
  in
  let nombre_membres_ok_ : bool =
    try
      try nombre_membres_ok_ ()
      with EmptyError -> (
        try
          if
            array_length membres_ >=! integer_of_string "4"
            && array_length membres_ <=! integer_of_string "8"
          then true
          else raise EmptyError
        with EmptyError -> false)
    with EmptyError -> raise NoValueProvided
  in
  let externes_ok_ : bool =
    try
      try externes_ok_ ()
      with EmptyError ->
        handle_default
          [|
            (fun (_ : _) ->
              if
                Array.fold_left
                  (fun (acc_ : integer) (membre_ : _) ->
                    if membre_.professeur then acc_ +! integer_of_string "1" else acc_)
                  (integer_of_string "0") membres_
                >=! array_length membres_ /! integer_of_string "2"
              then true
              else raise EmptyError);
            (fun (_ : _) ->
              if
                decimal_of_integer
                  (Array.fold_left
                     (fun (acc_ : integer) (membre_ : _) ->
                       if match membre_.sexe with Femme _ -> true | Homme _ -> false then
                         acc_ +! integer_of_string "1"
                       else acc_)
                     (integer_of_string "0") membres_)
                >=& decimal_of_integer (array_length membres_)
                    *& parite_minimale_representation_equilibree_
              then true
              else raise EmptyError);
            (fun (_ : _) ->
              if
                Array.fold_left
                  (fun (acc_ : integer) (membre_ : _) ->
                    if membre_.externe then acc_ +! integer_of_string "1" else acc_)
                  (integer_of_string "0") membres_
                >=! array_length membres_ /! integer_of_string "2"
              then true
              else raise EmptyError);
          |]
          (fun (_ : _) -> true)
          (fun (_ : _) -> false)
    with EmptyError -> raise NoValueProvided
  in
  {
    membres_out = membres_;
    parite_minimale_representation_equilibree_out = parite_minimale_representation_equilibree_;
    nombre_membres_ok_out = nombre_membres_ok_;
    parite_ok_out = parite_ok_;
    professeurs_ok_out = professeurs_ok_;
    president_ok_out = president_ok_;
    externes_ok_out = externes_ok_;
  }