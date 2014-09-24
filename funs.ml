
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
  module Keys = struct
    type t = int
    let left : t = 105
    let up   : t = 103
    let down : t = 108
    let enter : t = 28
    let right : t = 106
    let power : t = 116
    let menu  : t = 139
    let int_of_key k : int = k
  end
  external create : QApplication.t -> string -> string -> t = "caml_create_brick"
  external say : t-> string -> unit = "caml_brick_say"
  external sensor_value: t -> string -> int option = "caml_brick_sensor_value"
  external set_motor_power: t -> Motor.t -> int -> unit = "caml_brick_set_motor_power"

  external brick_keys_was_pressed: t -> int -> bool = "caml_brick_keys_was_pressed"
  let key_was_pressed b k = brick_keys_was_pressed b (Keys.int_of_key k)
end

module Display = struct
  type t
  external make : Brick.t -> t = "caml_create_display"
  external smile : t -> unit   = "caml_display_smile"
end


