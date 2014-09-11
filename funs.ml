
external send_an_int: int -> unit = "get_an_int"

module QApplication = struct
  type t
  external create : string array -> t = "caml_create_qapp"
  external exec   : t -> int  = "caml_qapp_exec"
end

module Sensor = struct
  type t = string
end

module Motor = struct
  type t = string
end

module Brick = struct
  type t
  external create : QApplication.t -> string -> string -> t = "caml_create_brick"
  external say : t-> string -> unit = "caml_brick_say"
  external sensor_value: t -> string -> int option = "caml_brick_sensor_value"
  external set_motor_power: t -> Motor.t -> int -> unit = "caml_brick_set_motor_power"
end

module Display = struct
  type t
  external make : Brick.t -> t = "caml_create_display"
  external smile : t -> unit   = "caml_display_smile"
end


