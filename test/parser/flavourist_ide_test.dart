import 'package:flavourist/src/parser/models/enums.dart';
import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:test/test.dart';

void main() {
	group('Flavourist ide', () {
		test('parses ide as a list', () {
			final config = Flavourist.parse('''
ide: [ vscode, cursor ]
flavors:
  demo:
    name: Demo
    applicationID: com.demo.app
''');

			expect(config.ide, [IDE.vscode, IDE.cursor]);
		});

		test('parses ide as a single string', () {
			final config = Flavourist.parse('''
ide: vscode
flavors:
  demo:
    name: Demo
    applicationID: com.demo.app
''');

			expect(config.ide, [IDE.vscode]);
		});

		test('omits ide when not set', () {
			final config = Flavourist.parse('''
flavors:
  demo:
    name: Demo
    applicationID: com.demo.app
''');

			expect(config.ide, isNull);
			expect(config.hasIdeTargets, isFalse);
		});

		test('rejects unknown ide values', () {
			expect(
				() => Flavourist.parse('''
ide: [ vscode, unknown ]
flavors:
  demo:
    name: Demo
    applicationID: com.demo.app
'''),
				throwsArgumentError,
			);
		});
	});
}
