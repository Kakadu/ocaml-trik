open Printf
open Funs

type config =
  { mutable configPath: string;
    mutable dirPath: string
  }

let config = { configPath = "./"; dirPath  = "./" }

let () =
  let args =
    [ ("-s", Arg.String (fun s -> config.configPath <- s), "config")
    ; ("-d", Arg.String (fun s -> config.dirPath <- s),    "dir")
    ]
  in
  Arg.parse args (fun s -> printf "Anonymous arg '%s'\n%!" s) "usage"

let say_hello i =
  while true do
    Printf.printf "%d %!" i;
    Thread.delay 1.
  done


let () = Funs.send_an_int 55

let sensor_d1: Sensor.t = "D1"

let motor_e1: Motor.t = "E1"
let motor_e2: Motor.t = "E2"
let motor_e3: Motor.t = "E3"

let motor_c1: Motor.t = "C1"
let motor_c2: Motor.t = "C2"
let motor_c3: Motor.t = "C3"

let () =
  let app = QApplication.create Sys.argv in
  let brick = Brick.create app config.configPath config.dirPath in
  (*Brick.say brick "Camelius bactrianus";*)

  let find_wall (sensor: Sensor.t) =
    while true do
      match Brick.sensor_value brick sensor with
      | Some x when x<50 -> Brick.set_motor_power brick motor_e1 100
      | Some x           ->
         printf "Wall is found: range %d\n%!" x;
         Brick.set_motor_power brick motor_e1 0;
         Thread.exit ()
      | None ->
         printf "Can't get value from sensor %s. Exit thread.\n%!" sensor;
         Thread.exit ()
    done
  in
  let thread_ids =
    [| Thread.create say_hello 0
     ; Thread.create find_wall sensor_d1
     |]
  in
  (*Array.init 4 (Thread.create say_hello) in*)
  (*Array.iter Thread.join thread_ids; *)
  (*flush_all ()*)
  QApplication.exec app |> ignore



