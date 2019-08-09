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
    throw ArgumentError("No Input given.");
  }

  File f;
  try {
    f = File(arguments['input']);
  } on FileSystemException {
    print("Error opening file");
  }

  Summary summary = await PanaFileParser(f).parse();

  String report = JUnitReport(base: "", package: summary.packageName)
      .toXml(await genReport(summary));

  await File(arguments['output']).writeAsString(report);
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

  return Report(suites);
}

Suite genMaintenanceSuite(Maintenance maintenance) {
  List<Test> tests = generateTests(maintenance.suggestions)
    ..add(Test(
        'Total Maintenance Score of ' +
            calculateMaintenanceScore(maintenance).toString(),
        0,
        null,
        [],
        [],
        false))
    ..reversed;

  return Suite('Pana Maintenance', null, tests);
}

Suite genHealthSuite(Health health) {
  List<Test> tests = generateTests(health.suggestions)
    ..add(Test('Total Health Score of ' + health.healthScore.toString(), 0,
        null, [], [], false))
    ..reversed;

  return Suite('Pana Health', null, tests);
}

List<Test> generateTests(List<Suggestion> suggestions) {
  List<Test> tests = [];

  for (Suggestion suggestion in suggestions) {
    if (suggestion.level == SuggestionLevel.bug ||
        suggestion.level == SuggestionLevel.hint) {
      tests.add(Test(getTitle(suggestion), 0, null, [],
          [getDescription(suggestion)], false));
    } else {
      Problem problem = Problem(getDescription(suggestion), null, true);
      tests.add(Test(getTitle(suggestion), 0, null, [problem], [], false));
    }
  }

  return tests;
}

String getDescription(Suggestion suggestion) {
  return suggestion.description;
}

String getTitle(Suggestion suggestion) {
  return suggestion.level.toUpperCase() +
      ': ' +
      suggestion.title +
      ' (' +
      (suggestion.score.toString() ?? 0) +
      ')';
}
