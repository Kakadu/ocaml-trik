extern "C" {
#include <mlvalues.h>
#include <threads.h>
#include <callback.h>
#include <memory.h>
#include <alloc.h>
}

#include <string>
#include <iostream>
#include <QtCore/QDebug>
#include <QApplication>

#define ARGC_N_ARGV(_argv,copy)\
  int argc_val = Wosize_val(_argv);\
  char **copy = new char*[argc_val];\
  for (int i = 0; i < argc_val; ++i) {\
	char *item = String_val(Field(_argv,i));\
    copy[i] = strdup(item);\
  }\
  int *argc = new int(argc_val);


extern "C" value caml_test_xxx(value _argv, value _cb) {
  CAMLparam2(_argv, _cb);
  CAMLlocal2(_ctx, _cb_res);

  ARGC_N_ARGV(_argv, copy);
  QApplication app(*argc, copy);

  _cb_res = caml_callback(_cb, Val_unit);
  Q_ASSERT(_cb_res == Val_unit);
  caml_enter_blocking_section();

  qDebug() << "executing app.exec()";
  app.exec();
  caml_leave_blocking_section();
  CAMLreturn(Val_unit);
}
