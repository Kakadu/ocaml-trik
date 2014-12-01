#include "mlheaders.h"

#include <QtCore/QDebug>
#include "trikControl/mailbox.h"

using namespace trikControl;

class MailboxWrapper : public QObject {
    value mObj;
public:
    explicit MailboxWrapper(value _obj, Mailbox* mailbox) {
        mObj = _obj;
        caml_register_global_root(&mObj);

        connect(mailbox, SIGNAL(newMessage(int,QString)),
                this,  SLOT(onMsgReceived(int,QString)) );
    }

public slots:
    void onMsgReceived(int sender, const QString &message) {
        qDebug() << sender << message;
        CAMLparam0();
        CAMLlocal2(_camlobj, _meth);
        CAMLlocalN(_args, 3);
        _camlobj = mObj;
        _meth = caml_get_public_method(_camlobj, caml_hash_variant("onreceive") );
        _args[0] = _camlobj;
        _args[1] = Val_int(sender);
        _args[2] = caml_copy_string( message.toLocal8Bit().data() );
        caml_callbackN(_meth, 3, _args);
        CAMLreturn0;
    }
};

// val create: Brick.t -> 'a -> Mailbox.t
extern "C" value caml_create_mailbox(value _brick, value _obj) {
    CAMLparam2(_brick, _obj);
    CAMLlocal1(_mailbox);

    Q_ASSERT(Is_block(_obj));
    Q_ASSERT(Tag_val(_obj) == Object_tag);

    fromt(Brick, brick);
    Mailbox *mailbox = brick->mailbox();
    MailboxWrapper *wrapper = new MailboxWrapper(_obj, mailbox);

    _mailbox = caml_alloc_small(1, Abstract_tag);
    (*((Mailbox **) &Field(_mailbox, 0))) = mailbox;

    CAMLreturn(_mailbox);
}

extern "C" value caml_mailbox_connect(value _mailbox, value _ipstr)  {
    CAMLparam2(_mailbox, _ipstr);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    mailbox->connect( QString_val(_ipstr) );

    CAMLreturn(Val_unit);
}

extern "C" value caml_mailbox_connect_port(value _mailbox, value _ipstr, value _port)  {
    CAMLparam3(_mailbox, _ipstr, _port);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    mailbox->connect( QString_val(_ipstr), Int_val(_port) );

    CAMLreturn(Val_unit);
}

extern "C" value caml_mailbox_send(value _mailbox, value _msgstr)  {
    CAMLparam2(_mailbox, _msgstr);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    mailbox->send( QString_val(_msgstr) );

    CAMLreturn(Val_unit);
}

extern "C" value caml_mailbox_send_hull(value _mailbox, value _hullN, value _msgstr)  {
    CAMLparam3(_mailbox, _msgstr, _hullN);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    mailbox->send( Int_val(_hullN), QString_val(_msgstr) );

    CAMLreturn(Val_unit);
}

extern "C" value caml_mailbox_hasMessages(value _mailbox)  {
    CAMLparam1(_mailbox);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    bool ans = mailbox->hasMessages();

    CAMLreturn(Val_bool(ans) );
}

extern "C" value caml_mailbox_serverIp(value _mailbox)  {
    CAMLparam1(_mailbox);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    QHostAddress ans = mailbox->serverIp();

    CAMLreturn( Val_QString(ans.toString()) );
}

extern "C" value caml_mailbox_myIp(value _mailbox)  {
    CAMLparam1(_mailbox);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    QHostAddress ans = mailbox->myIp();

    CAMLreturn( Val_QString(ans.toString()) );
}

extern "C" value caml_mailbox_setHullNumber(value _mailbox, value _num) {
    CAMLparam2(_mailbox, _num);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    mailbox->setHullNumber( Int_val(_num) );
    CAMLreturn(Val_unit);
}

extern "C" value caml_mailbox_myHullNumber(value _mailbox) {
    CAMLparam1(_mailbox);
    fromt(Mailbox, mailbox);
    Q_ASSERT(mailbox != nullptr);
    int ans = mailbox->myHullNumber();
    CAMLreturn( Val_int(ans) );
}
