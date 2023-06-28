let read_file filepath = In_channel.with_open_text filepath In_channel.input_all

(* TODO: improve regex *)
let extract_css_class_names css_string =
  let class_name_regex = Str.regexp {|\.\([a-zA-Z]+\)|} in

  let rec extract_classes acc pos =
    if pos >= String.length css_string then acc
    else
      try
        let _ = Str.search_forward class_name_regex css_string pos in
        let class_name = Str.matched_group 1 css_string in
        let new_pos = Str.match_end () in
        extract_classes (class_name :: acc) new_pos
      with Not_found -> acc
  in

  List.rev (extract_classes [] 0)

open Ppxlib

let extender_name = "css.module"
let context = Extension.Context.Structure_item

let extractor =
  let open Ast_pattern in
  pstr
    (pstr_value nonrecursive
       (value_binding ~pat:(ppat_var __) ~expr:(estring __) ^:: nil)
    ^:: nil)

let expander ~ctxt ident css_filepath =
  let loc = Expansion_context.Extension.extension_point_loc ctxt in
  let module Loc = struct
    let loc = loc
  end in
  let module Builder = Ast_builder.Make (Loc) in
  let source_filepath = Expansion_context.Extension.input_name ctxt in

  let css_absolute_filepath =
    match Filename.is_relative css_filepath with
    | false -> css_filepath
    | true -> css_filepath |> Filename.concat (Filename.dirname source_filepath)
  in

  let css_class_names =
    read_file css_absolute_filepath |> extract_css_class_names
  in

  let open Builder in
  let type_ =
    let object_fields =
      css_class_names
      |> List.map (fun css_class_name ->
             otag { txt = css_class_name; loc } [%type: string])
    in

    ptyp_object object_fields Closed
  in

  let attribute_ =
    attribute ~name:{ txt = "module"; loc }
      ~payload:(PStr [ pstr_eval (estring css_absolute_filepath) [] ])
  in

  let value_description_ =
    {
      pval_name = { txt = ident; loc };
      pval_type = type_;
      pval_prim = [ "default" ];
      pval_attributes = [ attribute_ ];
      pval_loc = loc;
    }
  in

  pstr_primitive value_description_

let extension = Extension.V3.declare extender_name context extractor expander
let css_module_rule = Context_free.Rule.extension extension

let () =
  Driver.V2.register_transformation ~rules:[ css_module_rule ]
    "typed-css-classes"
