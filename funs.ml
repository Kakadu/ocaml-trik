module QApplication = struct
  type t
  external create : string array -> t = "caml_create_qapp"
  external exec   : t -> int  = "caml_qapp_exec"
end
(*
module Sensor = struct
  type t = string
end
 *)
module Motor = struct
  type t
  external power: t -> int = "caml_motor_getPower"
  external set_power: t -> int -> unit = "caml_motor_setPower"
  external power_off: t -> unit = "caml_motor_powerOff"
end

module Point3D = struct
  type t = int*int*int
end
type point3d = Point3D.t

module LineSensor = struct
  type t
  external init: t -> bool -> unit = "caml_lineSensor_init"
  external read: t -> int*int*int = "caml_lineSensor_read" (* todo new type *)
  external detect: t -> unit = "caml_lineSensor_detect"
  external stop :  t -> unit = "caml_lineSensor_stop"
end

module ColorSensor = struct
  type t
  external init: t -> bool -> unit = "caml_colorSensor_init"
  external read: t -> int*int*int = "caml_colorSensor_read" (* todo maybe new type *)
  external stop :  t -> unit = "caml_colorSensor_stop"
end

module ObjectSensor = struct
  type t
  external init: t -> bool -> unit = "caml_objectSensor_init"
  external read: t -> int*int*int = "caml_objectSensor_read" (* todo new type *)
  external detect: t -> unit = "caml_objectSensor_detect"
  external stop :  t -> unit = "caml_objectSensor_stop"
end

module Encoder = struct
  type t
  external read : t -> int = "caml_encoder_read"
  external reset: t -> unit = "caml_encoder_reset"
end

module Gamepad = struct
  type t
  external reset: t -> unit = "caml_gamepad_reset"
end

module Display = struct
  type t
  (*external make : Brick.t -> t = "caml_create_display"*)
  external showImage: t -> string -> unit = "caml_display_showImage"
  external addLabel: t -> text:string -> x:int -> y:int -> unit = "caml_display_addLabel"
  external smile : t -> unit   = "caml_display_smile"
  external sadSmile : t -> unit   = "caml_display_sadSmile"
  external hide : t -> unit   = "caml_display_hide"
  external clear : t -> unit   = "caml_display_clear"
  external setPainerColor: t -> string -> unit = "caml_display_setPainterColor"
  external setBackground: t -> string -> unit = "caml_display_setBackground"
  external setPainterWidth: t -> int -> unit = "caml_display_setPainterWidth"
  external drawLine:t -> x1:int -> y1:int -> x2:int -> y2:int -> unit = "caml_display_drawLine"
  external drawPoint: t -> x:int -> y:int -> unit = "caml_display_drawPoint"
  external drawRect:t -> x1:int -> y1:int -> w:int -> h:int -> unit = "caml_display_drawRect"
  external drawEllipse: t -> x1:int -> y1:int -> w:int -> h:int -> unit = "caml_display_drawEllipse"

end

module Led = struct
  type t
  external red: t -> unit = "caml_led_red"
  external orange: t -> unit = "caml_led_orange"
  external green: t -> unit = "caml_led_green"
  external off: t -> unit = "caml_led_off"
end

module Brick = struct
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

  type t
  external create : QApplication.t -> string -> string -> t = "caml_create_brick"
  external reset  : t -> unit = "caml_brick_reset"
  external isEventDriven  : t -> unit = "caml_brick_isEventDriven"
  external playSound : t -> string -> unit = "caml_brick_playSound"
  external say  : t -> string -> unit = "caml_brick_say"
  external stop : t -> unit = "caml_brick_stop"
  external motor: t -> string -> Motor.t = "caml_brick_motor"
  (*external set_motor_power: t -> Motor.t -> int -> unit = "caml_brick_set_motor_power"*)
  external sensor_value: t -> string -> int option = "caml_brick_sensor_value"
  external acc_value: t -> point3d = "caml_brick_accelerometer_value"
  external gyro_value: t -> point3d = "caml_brick_gyroscope_value"
  external lineSensor: t -> LineSensor.t = "caml_brick_lineSensor"
  external colorSensor: t -> ColorSensor.t = "caml_brick_colorSensor"
  external objectSensor: t -> ObjectSensor.t = "caml_brick_objectSensor"
  external encoderSensor: t -> string -> ObjectSensor.t = "caml_brick_encoder"
  external batteryVoltage: t -> float = "caml_brick_batteryvoltage"
  external gamepad: t -> Gamepad.t = "caml_brick_gamepad"

  external brick_keys_was_pressed: t -> int -> bool = "caml_brick_keys_was_pressed"
  let key_was_pressed b k = brick_keys_was_pressed b (Keys.int_of_key k)
  external keys_reset: t -> unit = "caml_brick_keys_reset"

  external wait : t -> unit = "caml_brick_wait"
  external display : t -> Display.t = "caml_brick_display"
  external led: t -> Led.t = "caml_brick_led"
  external run: t ->  unit = "caml_brick_run"
  external quit: t -> unit = "caml_brick_quit"
end



