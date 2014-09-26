#include <stdio.h>

extern "C" {
#include <mlvalues.h>
#include <threads.h>
#include <memory.h>
#include <alloc.h>
}


#include <trikControl/brick.h>
#include <QtCore/QDebug>
#include <QtGui/QApplication>

using namespace trikControl;

#define fromt(typ, cval)     typ *cval = (typ*) (Field(_##cval,0));
#define maket(typ, cval) \
    _##cval = caml_alloc_small(1, Abstract_tag); \
    (*((typ **) &Field(_##cval, 0))) = cval;

#define declareProc(classname,valuename,procname)                       \
    extern "C" value caml_##valuename##_##procname(value _obj) {\
    CAMLparam1(_obj);\
    fromt(classname, obj);\
    Q_ASSERT(obj != NULL);\
    obj->procname();\
    CAMLreturn(Val_unit);\
    }

#define declareDetect(c,v) declareProc(c,v,detect)
#define declareStop(c,v)   declareProc(c,v,stop)
#define declareReset(c,v)  declareProc(c,v,reset)

#define declareInit(classname,valuename)     \
    extern "C" value caml_##valuename##_init(value _obj, value _show) {     \
    CAMLparam2(_obj,_show);\
    fromt(classname, obj);\
    Q_ASSERT(obj != NULL);\
    obj->init(Bool_val(_show) );                     \
    CAMLreturn(Val_unit);\
    }

#define QString_val(x) QString::fromLocal8Bit(String_val(x))
#define Val_none Val_int(0)
static value Val_some(value v) {
    CAMLparam1( v );
    CAMLlocal1( some );
    some = caml_alloc(1, 0);
    Store_field( some, 0, v );
    CAMLreturn( some );
}

#define ARGC_N_ARGV(_argv,copy)\
  int argc_val = Wosize_val(_argv);\
  char **copy = new char*[argc_val];\
  for (int i = 0; i < argc_val; ++i) {\
	char *item = String_val(Field(_argv,i));\
    copy[i] = strdup(item);\
  }\
  int *argc = new int(argc_val);


// string array -> QApplication.t (* never returns *)
extern "C" value caml_create_qapp(value _argv) {
    CAMLparam1(_argv);
    CAMLlocal3(_ans,_app,_engine);
    //caml_release_runtime_system();

    ARGC_N_ARGV(_argv, copy);
    QApplication *app = new QApplication(*argc, copy);

    _app = caml_alloc_small(1, Abstract_tag);
    (*((QApplication **) &Field(_app, 0))) = app;

    //caml_acquire_runtime_system();
    CAMLreturn(_app);
}

//  external exec   : t -> int  = "caml_qapp_exec"
extern "C" value caml_qapp_exec(value _app) {
    CAMLparam1(_app);

    QApplication *app = (QApplication*) (Field(_app,0));
    qDebug() << "App exec. release runtime " << __FILE__ ;
    caml_enter_blocking_section();
    app->exec();
    caml_leave_blocking_section();
    CAMLreturn(Val_int(0) );
}
// external create: QApplication.t -> string -> string -> Brick.t
extern "C" value caml_create_brick(value _qapp, value _config, value _start) {
    CAMLparam3(_qapp, _config, _start);
    CAMLlocal1(_brick);

    QApplication *app = (QApplication*) (Field(_qapp,0));
    QThread *guiThread = app->thread();
    Brick *brick = new Brick(*guiThread,
                             QString::fromLocal8Bit(String_val(_config)),
                             QString::fromLocal8Bit(String_val(_start))  );
    _brick = caml_alloc_small(1, Abstract_tag);
    (*((Brick **) &Field(_brick, 0))) = brick;
    CAMLreturn(_brick);
}

// reset: Brick.t -> unit
extern "C" value caml_brick_reset(value _brick) {
    CAMLparam1(_brick);
    fromt(Brick, brick);
    brick->reset();
    CAMLreturn(Val_unit);
}

// isEventDriven: Brick.t -> unit
extern "C" value caml_brick_isEventDriven(value _brick) {
    CAMLparam1(_brick);
    fromt(Brick, brick);
    brick->isInEventDrivenMode();
    CAMLreturn(Val_unit);
}

//
extern "C" value caml_brick_playSound(value _brick, value _filename) {
    CAMLparam2(_brick,_filename);
    fromt(Brick, brick);
    brick->playSound( QString_val(_filename) );

    CAMLreturn(Val_unit);
}

// say: Brick.t -> string -> unit
extern "C" value caml_brick_say(value _brick, value _msg) {
    CAMLparam2(_brick,_msg);
    fromt(Brick, brick);
    brick->say(QString::fromLocal8Bit(String_val(_msg)) );
    CAMLreturn(Val_unit);
}

// stop: Brick.t -> unit
declareStop (Brick,brick)

/////////////// Motors
// get_motor: Brick.t -> string -> Motor.t
extern "C" value caml_brick_motor(value _brick, value _m) {
    CAMLparam2(_brick, _m);
    CAMLlocal1(_motor);
    fromt(Brick, brick);
    Motor *motor = brick->motor(QString_val(_m));
    _motor = caml_alloc_small(1, Abstract_tag);
    (*((Motor **) &Field(_motor, 0))) = motor;

    CAMLreturn(_motor);
}
// power: Motor.t -> int
extern "C" value caml_motor_getpower(value _motor) {
    CAMLparam1(_motor);
    fromt(Motor, motor);
    CAMLreturn(Val_int(motor->power()));
}

// poweroff: Motor.t -> unit
extern "C" value caml_motor_poweroff(value _motor) {
    CAMLparam1(_motor);
    fromt(Motor, motor);
    motor->powerOff();
    CAMLreturn(Val_unit);
}

// setpower: Motor.t -> unit
extern "C" value caml_motor_setpower(value _motor, value _newval) {
    CAMLparam1(_motor);
    fromt(Motor, motor);
    motor->setPower(Int_val(_newval));
    CAMLreturn(Val_unit);
}

// go_forward: Brick.t -> Motor.t -> unit
extern "C" value caml_brick_set_motor_power(value _brick, value _m, value _power) {
    CAMLparam3(_brick, _m, _power);
    fromt(Brick, brick);
    //brick->say(QString::fromLocal8Bit(String_val(_msg)) );
    Motor *m = brick->motor(QString::fromLocal8Bit(String_val(_m)));
    m->setPower(Int_val(_power));
    CAMLreturn(Val_unit);
}

/////////////// PwmCapture is ignored

/////////////// Sensor class has only 1 method so we will not invent new type
// sensor: Brick.t -> string -> int option
extern "C" value caml_brick_sensor_value(value _brick, value _port) {
    CAMLparam2(_brick,_port);
    fromt(Brick, brick);
    Sensor *s = brick->sensor(QString::fromLocal8Bit(String_val(_port)) );
    if (s==NULL) {
        CAMLreturn(Val_none);
    } else {
        int r = s->read();
        CAMLreturn(Val_some(Val_int(r)));
    }
}

//////////////// We do not invent new type for accelerometer
// accelerometer: Brick.t -> Point3D.t (as tuple int*int*int)
extern "C" value caml_brick_accelerometer_value(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_ans);
    fromt(Brick, brick);
    QVector<int> vals = brick->accelerometer()->read();
    Q_ASSERT(vals.count() == 3);

    _ans = caml_alloc(3, 0);
#define F(n) Store_field( _ans, n, Val_int(vals.at(n)) );
    F(0);
    F(1);
    F(2);

    CAMLreturn(_ans);
}

//////////////// We do not invent new type for gyroscope
// gyroscope: Brick.t -> Point3D.t (as tuple int*int*int)
extern "C" value caml_brick_gyroscope_value(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_ans);
    fromt(Brick, brick);
    QVector<int> vals = brick->gyroscope()->read();
    Q_ASSERT(vals.count() == 3);

    _ans = caml_alloc(3, 0);
#define F(n) Store_field( _ans, n, Val_int(vals.at(n)) );
    F(0);
    F(1);
    F(2);

    CAMLreturn(_ans);
}

// lineSensor: Brick.t -> LineSensor.t
extern "C" value caml_brick_lineSensor(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_lineSensor);
    fromt(Brick, brick);

    LineSensor *lineSensor = brick->lineSensor();
    _lineSensor = caml_alloc_small(1, Abstract_tag);
    (*((LineSensor **) &Field(_lineSensor, 0))) = lineSensor;

    CAMLreturn(_lineSensor);
}

// init: LineSensor.t -> bool -> unit
extern "C" value caml_lineSensor_init(value _lineSensor, value _show) {
    CAMLparam2(_lineSensor, _show);
    fromt(LineSensor, lineSensor);
    Q_ASSERT(lineSensor != NULL);

    lineSensor->init(Bool_val(_show));
    CAMLreturn(Val_unit);
}

// read: LineSensor.t -> int*int*int  (* (coordinate,probablity,mass) *)
extern "C" value caml_lineSensor_read(value _lineSensor) {
    CAMLparam1(_lineSensor);
    CAMLlocal1(_ans);
    fromt(LineSensor,lineSensor);
    QVector<int> vals = lineSensor->read();
    Q_ASSERT(vals.count() == 3);

    _ans = caml_alloc(3, 0);
#define F(n) Store_field( _ans, n, Val_int(vals.at(n)) );
    F(0);
    F(1);
    F(2);

    CAMLreturn(_ans);
}

// detect: LineSensor.t -> unit
extern "C" value caml_lineSensor_detect(value _lineSensor) {
    CAMLparam1(_lineSensor);
    fromt(LineSensor, lineSensor);
    Q_ASSERT(lineSensor != NULL);

    lineSensor->detect();
    CAMLreturn(Val_unit);
}

// stop: LineSensor.t -> unit
declareStop(LineSensor,lineSensor)
//////////////////// LineSensor end

// get_colorSensor: Brick.t -> Motor.t
extern "C" value caml_brick_colorSensor(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_colorSensor);
    fromt(Brick, brick);
    ColorSensor *colorSensor = brick->colorSensor();
    maket(ColorSensor,colorSensor);
    CAMLreturn(_colorSensor);
}

//////////////// Color sensor
// init: ColorSensor.t -> bool -> unit
extern "C" value caml_colorSensor_init(value _colorSensor, value _show) {
    CAMLparam2(_colorSensor, _show);
    fromt(ColorSensor, colorSensor);
    Q_ASSERT(colorSensor != NULL);

    colorSensor->init(Bool_val(_show));
    CAMLreturn(Val_unit);
}
// read: ColorSensor.t -> m:int -> n:int -> Point3d.t
extern "C" value caml_colorSensor_read(value _colorSensor, value _m, value _n) {
    CAMLparam3(_colorSensor, _m, _n);
    CAMLlocal1(_ans);
    fromt(ColorSensor, colorSensor);
    Q_ASSERT(colorSensor != NULL);
    QVector<int> vals = colorSensor->read(Int_val(_m), Int_val(_n) );
    Q_ASSERT(vals.count() == 3);

    _ans = caml_alloc(3, 0);
#define F(n) Store_field( _ans, n, Val_int(vals.at(n)) );
    F(0);  F(1);   F(2);

    CAMLreturn(_ans);
}

// stop: ColorSensor.t -> unit
declareStop(ColorSensor,colorSensor)
//////////////// End of Color sensor

// get_objectSensor: Brick.t -> ObjectSensor.t
extern "C" value caml_brick_objectSensor(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_objectSensor);
    fromt(Brick, brick);
    ObjectSensor *objectSensor = brick->objectSensor();
    maket(ObjectSensor,objectSensor);
    CAMLreturn(_objectSensor);
}

/////////////// Object sensor
// init: ObejctSensor.t -> bool -> unit
declareInit(ObjectSensor,objectSensor)
// detect: ObjectSensor.t -> unit
declareDetect(ObjectSensor,objectSensor)
// stop: ObjectSensor.t -> unit
declareStop(ObjectSensor,objectSensor)
// read: ObjectSensor.t -> int*int*int (* (x,y,size) *)
extern "C" value caml_objectSensor_read(value _objectSensor) {
    CAMLparam1(_objectSensor);
    CAMLlocal1(_ans);
    fromt(ObjectSensor, objectSensor);
    Q_ASSERT(objectSensor != NULL);
    QVector<int> vals = objectSensor->read();
    Q_ASSERT(vals.count() == 3);

    _ans = caml_alloc(3, 0);
#define F(n) Store_field( _ans, n, Val_int(vals.at(n)) );
    F(0);  F(1);   F(2);

    CAMLreturn(_ans);
}
/////////////// Object sensor end

// get_encoder: Brick.t -> string -> Encoder.t
extern "C" value caml_brick_encoder(value _brick, value _port) {
    CAMLparam1(_brick);
    CAMLlocal1(_encoder);
    fromt(Brick, brick);
    Encoder *encoder = brick->encoder(QString_val(_port));
    maket(Encoder,encoder);
    CAMLreturn(_encoder);
}

/////////////// Encoder
// read: Encoder.t -> int
extern "C" value caml_encoder_read(value _encoder) {
    CAMLparam1(_encoder);
    fromt(Encoder, encoder);
    Q_ASSERT(encoder != NULL);
    int ans = encoder->read();
    CAMLreturn(Val_int(ans) );
}
// reset: Encoder.t -> unit
declareProc(Encoder,encoder,reset)
/////////////// Encoder end


// batterVoltage: Brick.t -> float
extern "C" value caml_brick_batteryvoltage(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_ans);
    fromt(Brick, brick);
    CAMLreturn( caml_copy_double( brick->battery()->readVoltage() ) );
}



// Keys we temporarily declare without new type

// Brick.t -> int -> bool
extern "C" value caml_brick_keys_was_pressed(value _brick, value _keyCode) {
    CAMLparam2(_brick, _keyCode);

    fromt(Brick, brick);
    int keyCode = Int_val(_keyCode);
    bool ans = brick->keys()->wasPressed(keyCode);

    CAMLreturn(Val_bool(ans));
}

// reset: Brick.t -> unit
extern "C" value caml_brick_keys_reset(value _brick) {
    CAMLparam1(_brick);
    fromt(Brick, brick);
    brick->keys()->reset();
    CAMLreturn(Val_unit);
}


// get_gamepad: Brick.t -> GamePad.t
extern "C" value caml_brick_gamePad(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_pad);
    fromt(Brick, brick);
    Gamepad *pad = brick->gamepad();
    maket(Gamepad,pad);
    CAMLreturn(_pad);
}
/////////////////// GamePad
// reset: GamePad.t -> unit
declareReset(Gamepad,gamepad)
// buttonWasPressed: GamePad.t -> int -> bool
// isPadPressed: GamePad.t -> int -> bool
// padX: GamePad.t -> int -> int
// padY: GamePad.t -> int -> int
// THIS IS TODO
/////////////////// GamePad end

// wait: Brick.t -> int -> unit
extern "C" value caml_brick_wait(value _brick, value _ms) {
    CAMLparam1(_brick);
    fromt(Brick, brick);
    brick->wait(Int_val(_ms));
    CAMLreturn(Val_unit);
}

// time: Brick.t -> int64


// display: Brick.t -> Display.t
extern "C" value caml_create_display(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_display);
    fromt(Brick, brick);
    Display *display = brick->display();

    maket(Display,display);
    CAMLreturn(_display);
}
////////////// Display
extern "C" value caml_display_smile(value _display) {
    CAMLparam1(_display);
    fromt(Display, display);
    display->smile();
    CAMLreturn(Val_unit);
}
////////////// Display end

// get_LED: Brick.t -> LED.t
extern "C" value caml_brick_led(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_led);
    fromt(Brick, brick);
    Led *led = brick->led();
    maket(Led,led);
    CAMLreturn(_led);
}

/////////////// LED
declareProc(Led,led,red)
declareProc(Led,led,orange)
declareProc(Led,led,green)
declareProc(Led,led,off)

////////////// LED end

declareProc(Brick,brick,run)
declareProc(Brick,brick,quit)

// system
// Maybe let this be done in OCaml manner?
