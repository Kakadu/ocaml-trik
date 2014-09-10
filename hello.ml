(* Compilation (native):
$ ocamlopt -thread unix.cmxa threads.cmxa threads_hello.ml -o threads_hello
*)

let say_hello (i, msg) =
  Printf.printf "Thread %d says %s\n" i msg

let () = Funs.send_an_int 55

(*
let () = 
  let thread_ids = Array.init 4 (fun i -> Thread.create say_hello (i, "Hello World!")) in
  Array.iter Thread.join thread_ids;
  flush_all ()

*)

