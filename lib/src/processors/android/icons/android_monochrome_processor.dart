import 'package:flavourist/src/parser/models/flavourist.dart';
import 'package:flavourist/src/processors/commons/image_resizer_processor.dart';
import 'package:flavourist/src/processors/commons/queue_processor.dart';
import 'package:flavourist/src/utils/constants.dart';
import 'package:sprintf/sprintf.dart';

class AndroidMonochromeProcessor extends QueueProcessor {
	static const _entries = {
		'drawable-mdpi': Size(width: 108, height: 108),
		'drawable-hdpi': Size(width: 162, height: 162),
		'drawable-xhdpi': Size(width: 216, height: 216),
		'drawable-xxhdpi': Size(width: 324, height: 324),
		'drawable-xxxhdpi': Size(width: 432, height: 432),
	};

	AndroidMonochromeProcessor(
		String monochromeSource,
		String flavorName, {
		required Flavourist config,
	}) : super(
			_entries
					.map(
						(folder, size) => MapEntry(
							folder,
							ImageResizerProcessor(
								monochromeSource,
								sprintf(Constants.androidMonochromePath, [
									flavorName,
									folder,
								]),
								size,
								config: config,
							),
						),
					)
					.values,
			config: config,
		);

	@override
	String toString() => 'AndroidMonochromeProcessor';
}
