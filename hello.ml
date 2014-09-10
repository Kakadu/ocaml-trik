(* Compilation (native):
$ ocamlopt -thread unix.cmxa threads.cmxa threads_hello.ml -o threads_hello
*)

let say_hello i =
  while true do
    Printf.printf "%d %!" i
  done

let () = Funs.send_an_int 55

let () =
  let thread_ids = Array.init 4 (Thread.create say_hello) in
  Array.iter Thread.join thread_ids;
  flush_all ()



