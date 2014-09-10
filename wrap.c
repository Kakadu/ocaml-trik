#include <stdio.h>
#include <mlvalues.h>

CAMLprim value
get_an_int( value v )
{
    int i;
    i = Int_val(v);
    printf("%d\n", i);
    return Val_unit;
}

