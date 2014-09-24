open Printf
open Funs

type config =
  { mutable configPath: string;
    mutable dirPath: string;
    mutable engineSensors: string list;
    mutable rangeSensor: string;
  }

let config = { configPath = "./"; dirPath  = "./"; rangeSensor="A2"; engineSensors=[] }

let () =
  let args =
    [ ("-s", Arg.String (fun s -> config.configPath <- s), "config")
    ; ("-d", Arg.String (fun s -> config.dirPath <- s),    "dir")
    ; ("-r", Arg.String (fun s -> config.rangeSensor <- s),"range sensor")
    ; ("-e", Arg.String (fun s -> config.engineSensors <- s::config.engineSensors), "engine sensor")
    ]
  in
  Arg.parse args (fun s -> printf "Anonymous arg '%s'\n%!" s) "usage"

let say_hello () =
  let delay = 10 in
  while true do
    Printf.printf "Saying Hello every %d seconds\n%!" delay;
    let _ = Thread.delay (float_of_int delay) in
    ()
  done

let () =
  let app = QApplication.create Sys.argv in
  let brick = Brick.create app config.configPath config.dirPath in
  (*Brick.say brick "Camelius bactrianus";*)
  let current_power = ref 10 in

  let set_engine_power newval =
    List.iter (fun s -> Brick.set_motor_power brick s newval) config.engineSensors
  in
  let incr_engine_power () =
    current_power := !current_power + 10;
    printf "current power value = %d\n%!" !current_power;
    set_engine_power !current_power;
  in
  let decr_engine_power () =
    current_power := !current_power - 10;
    printf "current power value = %d\n%!" !current_power;
    set_engine_power !current_power;
  in
  let buttons_monitor was_pressed =
    while true do
      if was_pressed Brick.Keys.power then (print_endline "shutdown pressed"; exit 0);
      if was_pressed Brick.Keys.menu then (print_endline "menu pressed"; exit 0);
      if was_pressed Brick.Keys.right then (print_endline "more power"; incr_engine_power ());
      if was_pressed Brick.Keys.left  then (print_endline "less power"; decr_engine_power ());
      Thread.delay 1.
  done
  in
  let find_wall (rangeSensor: Sensor.t) =
    while true do
      match Brick.sensor_value brick rangeSensor with
      | Some x when x<50 ->
         List.iter (fun motor -> Brick.set_motor_power brick motor 10) config.engineSensors;
      | Some x           ->
         printf "Wall is found: range %d\n%!" x;
         set_engine_power 0;
         Thread.exit ()
      | None ->
         printf "Can't get value from sensor %s. Exit thread.\n%!" rangeSensor;
         Thread.exit ()
    done
  in
  let _thread_ids =
    [ Thread.create say_hello ()
    ; Thread.create find_wall config.rangeSensor
    ; Thread.create buttons_monitor (Brick.key_was_pressed brick)
    ]
  in

  at_exit (fun () -> List.iter (fun s -> Brick.set_motor_power brick s 0) config.engineSensors);

  QApplication.exec app |> ignore



