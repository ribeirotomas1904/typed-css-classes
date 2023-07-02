let () =
  Ppxlib.Driver.V2.register_transformation
    ~rules:[ Css_import.rule; Css_module.rule ]
    "typed-css-classes"
