#pragma once

#include <stdio.h>

extern "C" {
#include <caml/mlvalues.h>
#include <caml/threads.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/callback.h>
}

#include <QtCore/QDebug>
#include <QtGui/QApplication>

#define fromt(typ, cval)     typ *cval = (typ*) (Field(_##cval,0)); Q_ASSERT(cval != NULL);
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

#define Val_QString(s)   caml_copy_string(s.toLocal8Bit())
#define QString_val(x) QString::fromLocal8Bit(String_val(x))
#define Val_none Val_int(0)

value Val_some(value);

#include <trikControl/brick.h>
