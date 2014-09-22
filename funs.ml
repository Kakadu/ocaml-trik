(*
external send_an_int: int -> unit = "get_an_int"

module QApplication = struct
  type t
  external create : string array -> t = "caml_create_qapp"
  external exec   : t -> int  = "caml_qapp_exec"
end
                      *)

external run_with_qapplication : string array -> (unit -> unit) -> unit = "caml_run_QQmlApplicationEngine"
