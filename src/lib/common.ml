let read_file filepath = In_channel.with_open_bin filepath In_channel.input_all

let extract_css_class_names css_filepath =
  let parser_basename = "parser.bundle.js" in
  let parser_filepath =
    (* TODO: validate cli args *)
    parser_basename |> Filename.concat (Filename.dirname Sys.argv.(0))
  in

  (* TODO: validate exit code *)
  let _ =
    Filename.quote_command "chmod" [ "+x"; parser_filepath ] |> Sys.command
  in
  let temp_file_path = Filename.temp_file "css_class_names" "" in

  (* TODO: validate exit code *)
  let _ =
    Filename.quote_command parser_filepath [ css_filepath; temp_file_path ]
    |> Sys.command
  in

  read_file temp_file_path |> String.split_on_char ','
