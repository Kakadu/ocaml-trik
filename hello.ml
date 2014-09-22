open Printf
open Funs

let say_hello i =
  while true do
    print_endline "say hello";
    Printf.printf "hello %d\n" i;
    Thread.delay 5.
  done

let find_wall () =
  while true do
    print_endline "find wall";
    Thread.delay 5.;
  done

let () =

  let init () =
    let _thread_ids =
      [| Thread.create say_hello 0
       ; Thread.create find_wall ()
        |]
    in
    ()
  in
  run_with_qapplication Sys.argv init




