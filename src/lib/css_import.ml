open Ppxlib
open Common

let extender_name = "css.import"
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

  let css_class_names = extract_css_class_names css_absolute_filepath in

  let open Builder in
  let pstr_extension_ =
    pstr_extension
      ( { txt = "raw"; loc },
        PStr [ pstr_eval (estring ("import \"" ^ css_filepath ^ "\"")) [] ] )
      []
  in

  let type_ =
    let object_fields =
      css_class_names
      |> List.map (fun css_class_name ->
             otag { txt = css_class_name; loc } [%type: string])
    in

    ptyp_object object_fields Closed
  in

  let object_expression =
    let object_fields =
      css_class_names
      |> List.map (fun css_class_name ->
             let quoted_css_class_name = "\"" ^ css_class_name ^ "\"" in
             quoted_css_class_name ^ ":" ^ quoted_css_class_name)
      |> String.concat ","
      |> fun properties -> "{" ^ properties ^ "}"
    in

    pexp_constraint
      (pexp_extension
         ({ txt = "raw"; loc }, PStr [ pstr_eval (estring object_fields) [] ]))
      type_
  in

  let pstr_value_ =
    pstr_value Nonrecursive
      [ value_binding ~pat:(pvar ident) ~expr:object_expression ]
  in

  pstr_include (include_infos (pmod_structure [ pstr_extension_; pstr_value_ ]))

let extension = Extension.V3.declare extender_name context extractor expander
let rule = Context_free.Rule.extension extension
