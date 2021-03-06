import 'dart:async';
import 'dart:ui';

import 'package:diagnosa/moduls/beranda/beranda.dart';
import 'package:diagnosa/moduls/diagnosa/data_master.dart';
import 'package:diagnosa/moduls/penyakit/detail_penyakit.dart';
import 'package:diagnosa/utils/colors.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_sweet_alert/flutter_sweet_alert.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:sweet_alert_dialogs/sweet_alert_dialogs.dart';

class DiagnosaPage extends StatefulWidget {
  DiagnosaPage({Key key, this.title}) : super(key: key);

  final String title;
  static final String tag = "/diagnosa";

  @override
  _DiagnosaPageState createState() => _DiagnosaPageState();
}

class _DiagnosaPageState extends State<DiagnosaPage>
    with SingleTickerProviderStateMixin {
  var _answerMap = {
    'P001': 0,
    'P002': 0,
    'P003': 0,
    'P004': 0,
    'P005': 0,
    'P006': 0,
    'P007': 0,
    'P008': 0,
    'P009': 0,
    'P010': 0,
    'P011': 0
  };
  var _currentQestion = 0;
  var _diagnozed = '';
  var master = Master();
  var gejala;
  var penyakit;
  var gejalaPenyakit;

  void _findDiagnozed(String k, int v) {
    if (v >= 4) _diagnozed = k;
  }

  void _askQuestion(String gejalaId, String question) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return RichAlertDialog(
            alertTitle: richTitle("Diagnosa Penyakit Anda"),
            alertSubtitle: richSubtitle("Apakah $question ?"),
            alertType: RichAlertType.SUCCESS,
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text("YA"),
                onPressed: () {
                  gejalaPenyakit[gejalaId]
                      .forEach((penyakitId) => _answerMap[penyakitId] += 1);
                  Navigator.pop(context);
                },
              ),
              VerticalDivider(
                width: 50,
              ),
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text("TIDAK"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(context, BerandaPage.tag,
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          );
        });
    _answerMap.forEach(_findDiagnozed);
    if (_diagnozed == '') {
      _askQuestion(gejala.keys.toList()[++_currentQestion],
          gejala.values.toList()[_currentQestion]);
    } else {
      final hasil = penyakit[_diagnozed];
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return RichAlertDialog(
              alertTitle: richTitle("Hasil Diagnosa"),
              alertSubtitle: Text(
                "Berdasarkan gejala-gejala yang telah Anda jawab, kami mendiagnosa bahwa Anda mengalami : $hasil",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
              alertType: RichAlertType.SUCCESS,
              actions: <Widget>[
                FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text("Tutup"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text("Solusi"),
                  onPressed: () {
                    Navigator.pop(context);
                    viewDetail(_diagnozed);
                  },
                ),
              ],
            );
          });
    }
    // SweetAlert.dialog(
    //   type: AlertType.NORMAL,
    //   cancelable: true,
    //   title: "Diagnosa Penyakit Anda",
    //   content: "Apakah $question ?",
    //   showCancel: true,
    //   cancelButtonText: "Tidak",
    //   confirmButtonText: "Ya",
    //   closeOnConfirm: false,
    //   closeOnCancel: false,
    // ).then((value) {
    //   if (value) {
    //     //Jawaban Iya
    //     gejalaPenyakit[gejalaId]
    //         .forEach((penyakitId) => _answerMap[penyakitId] += 1);
    //   } else {
    //     //Jawaban Tidak
    //   }
    //   //tampilkan dialog selanjutnya atau munculkan hasil diagnosa
    //   _answerMap.forEach(_findDiagnozed);
    //   if (_diagnozed == '') {
    //     SweetAlert.close(closeWithAnimation: true);
    //     _askQuestion(gejala.keys.toList()[++_currentQestion],
    //         gejala.values.toList()[_currentQestion]);
    //   } else {
    //     SweetAlert.close(closeWithAnimation: true);
    //     final hasil = penyakit[_diagnozed];
    //     SweetAlert.dialog(
    //       type: AlertType.SUCCESS,
    //       cancelable: true,
    //       title: "Hasil Diagnosa",
    //       content:
    //           "Berdasarkan gejala-gejala yang telah Anda jawab, kami mendiagnosa bahwa Anda mengalami : $hasil",
    //       showCancel: true,
    //       closeOnConfirm: false,
    //       cancelButtonText: "Tutup",
    //       confirmButtonText: "Solusi",
    //     ).then((value) {
    //       if (value) {
    //         SweetAlert.close(closeWithAnimation: true);
    //         viewDetail(_diagnozed);
    //       }
    //       // Navigator.pop(context);
    //     });
    //   }
    // });
  }

  viewDetail(String idPenyakit) async {
    var p = await master.getPenyakit(idPenyakit);
    var g = await master.getGejalaPenyakit(idPenyakit);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPenyakitPage(
          penyakit: p,
          gejala: g.values.join('\n'),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initDb();
    Timer(Duration(seconds: 2),
        () => _askQuestion(gejala.keys.toList()[0], gejala.values.toList()[0]));
  }

  initDb() async {
    gejala = await master.gejala();
    penyakit = await master.penyakit();
    gejalaPenyakit = await master.gejalaPenyakit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          title: Text('Diagnosa'),
          centerTitle: true,
          backgroundColorEnd: BlueRaspberry.end,
          backgroundColorStart: BlueRaspberry.start,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage('images/diagnosa.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            ),
          ),
        ));
  }
}
