open Printf

let say_hello i =
  while true do
    print_endline "say hello";
    Printf.printf "hello %d\n%!" i;
    Thread.delay 1.
  done

let find_wall () =
  while true do
    print_endline "find wall";
    Thread.delay 2.;
  done

let () =
  print_endline "ocaml is starting up...";
  let init () =
    let _thread_ids =
      [| Thread.create say_hello 0
       ; Thread.create find_wall ()
        |]
    in
    ()
  in
  Thread.delay 3.;
  init ();
  (*while true do () done;*)
  Funs.run_with_qapplication Sys.argv (fun () -> ());
  ()
