extern "C" {
#include <mlvalues.h>
#include <threads.h>
#include <callback.h>
#include <memory.h>
#include <alloc.h>
}


#include <QtCore/QDebug>
#include <QApplication>

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


extern "C" value caml_run_QQmlApplicationEngine(value _argv, value _cb) {
  CAMLparam2(_argv, _cb);
  CAMLlocal2(_ctx, _cb_res);
  qDebug() << "App exec. inside caml_run_QQmlApplicationEngine. "<<__FILE__<< ", line " << __LINE__ ;
  caml_enter_blocking_section();

  ARGC_N_ARGV(_argv, copy);
  QApplication app(*argc, copy);

  caml_leave_blocking_section();
  _cb_res = caml_callback(_cb, Val_unit);
  caml_enter_blocking_section();

  Q_ASSERT(_cb_res == Val_unit);

  qDebug() << "executing app.exec()";
  app.exec();
  CAMLreturn(Val_unit);
}


