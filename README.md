# Pana to JUnit
A dart application to convert [pana](https://github.com/dart-lang/pana) JSON output to JUnit XML format, for example to be displayed in [Jenkins CI](https://github.com/jenkinsci/jenkins).

# Example

```bash
pub global run pana redis > out.json
pub global run pana_to_junit --input out.json --output report.xml
```