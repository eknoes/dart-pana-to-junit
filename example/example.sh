# Run Pana on a package, e.g. redis
pub global run pana redis > out.json

# Use Pana to JUnit to convert pana output to JUnit Report
pub global run pana_to_junit --input out.json --output report.xml
