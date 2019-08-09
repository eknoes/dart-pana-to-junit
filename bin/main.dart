import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:junitreport/junitreport.dart';
import 'package:pana/pana.dart';
import 'package:testreport/testreport.dart';
import 'package:pana/models.dart';
import 'package:pana_to_junit/pana_to_junit.dart';

Future<Null> main(List<String> args) async {
  var arguments = getArgParser().parse(args);

  if (arguments['input'] == null) {
    print("No Input give.");
    return;
  }

  File f;
  try {
    f = File(arguments['input']);
  } on FileSystemException {
    print("Error opening file");
  }

  Summary summary = await PanaFileParser(f).parse();

  String report = JUnitReport(base: "TestBase", package: "TestPackage").toXml(await genReport(summary));

  await File(arguments['output']).writeAsString(report);
  print(report);
}

ArgParser getArgParser() {
  var parser = ArgParser()
    ..addOption('input', abbr: 'i', help: """
the path to the 'json' file containing the output of 'pana'.""")
    ..addOption('output', abbr: 'o', defaultsTo: 'out.xml', help: """
the path of the to be generated junit xml file.""");

  return parser;
}

Report genReport(Summary summary) {
  List<Suite> suites = [];

  suites.add(genHealthSuite(summary.health));
  suites.add(genMaintenanceSuite(summary.maintenance));
//  suites.addAll(genFileSuites(summary.dartFiles));

  return Report(suites);
}

Suite genMaintenanceSuite(Maintenance maintenance) {
  List<Test> tests = [];

  tests.add(Test('Health Score of ' + calculateMaintenanceScore(maintenance).toString(), 0, null, [], [], false));

  return Suite('Pana Maintenance', 'dart', tests);
}

Suite genHealthSuite(Health health) {
  List<Test> tests = [];

  tests.add(Test('Health Score of ' + health.healthScore.toString(), 0, null, [], [], false));

  return Suite('Pana Health', 'dart', tests);
}