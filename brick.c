#include "mlheaders.h"

using namespace trikControl;


class SensorWrapper : public QObject {
    value mObj;
public:
    explicit SensorWrapper(value _obj, Sensor *sensor) {
        mObj = _obj;
        caml_register_global_root(&mObj);

        connect(sensor, SIGNAL(newData(int,int)),
                this,  SLOT(onNewData(int,int)) );
    }

public slots:
    void onNewData(int data, int rawData) {
        CAMLparam0();
        CAMLlocal2(_camlobj, _meth);
        CAMLlocalN(_args, 3);
        _camlobj = mObj;
        _meth = caml_get_public_method(_camlobj, caml_hash_variant("onNewData") );
        _args[0] = _camlobj;
        _args[1] = Val_int(data);
        _args[2] = Val_int(rawData);
        caml_callbackN(_meth, 3, _args);
        CAMLreturn0;
    }
};


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

// sensor: Brick.t -> string -> bool
extern "C" value caml_brick_has_sensor(value _brick, value _port) {
    CAMLparam2(_brick, _port);
    fromt(Brick, brick);
    Sensor *s = brick->sensor(QString::fromLocal8Bit(String_val(_port)) );
}

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

// sensor: Brick.t -> string -> int option
extern "C" value caml_brick_sensor_rawvalue(value _brick, value _port) {
    CAMLparam2(_brick,_port);
    fromt(Brick, brick);
    Sensor *s = brick->sensor(QString::fromLocal8Bit(String_val(_port)) );
    if (s==NULL) {
        CAMLreturn(Val_none);
    } else {
        int r = s->readRawData();
        CAMLreturn(Val_some(Val_int(r)));
    }
}

// wrap_sensor: Brick.t -> port:string -> < onNewData: int -> int -> unit; .. > -> bool
extern "C" value caml_wrap_sensor(value _brick, value _port, value _obj) {
    CAMLparam3(_brick, _port, _obj);
    fromt(Brick, brick);
    Sensor *s = brick->sensor(QString::fromLocal8Bit(String_val(_port)) );
    if (s==NULL)
        CAMLreturn(Val_bool(false));

    SensorWrapper *wrapper = new SensorWrapper(_obj, s);
    // let's do not return wrapper.
    CAMLreturn(Val_bool(true));
}
