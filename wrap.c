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

#define fromt(typ, cval)     typ *cval = (typ*) (Field(_##cval,0));
#define maket(typ, cval) \
    _##cval = caml_alloc_small(1, Abstract_tag); \
    (*((typ **) &Field(_##cval, 0))) = cval;


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

// say: Brick.t -> string -> unit
extern "C" value caml_brick_say(value _brick, value _msg) {
    CAMLparam2(_brick,_msg);
    fromt(Brick, brick);
    brick->say(QString::fromLocal8Bit(String_val(_msg)) );
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

// external create: QApplication.t -> string -> string -> Brick.t
extern "C" value caml_create_display(value _brick) {
    CAMLparam1(_brick);
    CAMLlocal1(_display);
    fromt(Brick, brick);
    Display *display = brick->display();

    maket(Display,display);
    CAMLreturn(_display);
}

extern "C" value caml_display_smile(value _display) {
    CAMLparam1(_display);
    fromt(Display, display);
    display->smile();
    CAMLreturn(Val_unit);
}

// int -> unit
extern "C" CAMLprim value get_an_int(value v)
{
    int i;
    i = Int_val(v);
    printf("%d\n", i);
    return Val_unit;
}

