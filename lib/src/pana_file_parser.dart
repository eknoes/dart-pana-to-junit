
part of pana_parser;

class PanaFileParser {
  final File file;

  PanaFileParser(this.file);

  Future<Summary> parse() async {
    String json = await file.readAsString();
    Map summaryJson = jsonDecode(json);

    return Summary.fromJson(summaryJson);
  }
}

