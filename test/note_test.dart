import 'package:alfred_noteplan/note.dart';
import 'package:alfred_noteplan/hyperlink.dart';
import 'package:alfred_noteplan/strings.dart';
import 'package:test/test.dart';

void main() {
	final Note emptyNote = Note(
		'example/folder/Note.md',
		'''
		'''.unindent(),
		DateTime.now().millisecondsSinceEpoch,
		1 // default note
	);

	test("Empty note", () {
		expect(emptyNote.hyperlinks.isEmpty, true);
		expect(emptyNote.code_bits.isEmpty, true);
		expect(emptyNote.title, "Note");
	});

	///   ///   ///   ///   ///

	final Note pureNote = Note(
		'example/markdown/Note with pure Markdown.md',
		'''
		# This is the title

		- item 1
		- item 2
		- item 3

		## Shop for these

		* Cookies
		* Bread
		* Don't forget to pick up milk (!)
		'''.unindent(),
		DateTime.now().millisecondsSinceEpoch,
		1
	);

	test("Note without frontmatter", () {
		expect(pureNote.hyperlinks.isEmpty, true);
		expect(pureNote.code_bits.isEmpty, true);
		expect(pureNote.title, "This is the title");
		expect(pureNote.content, """
		- item 1
		- item 2
		- item 3

		## Shop for these

		* Cookies
		* Bread
		* Don't forget to pick up milk (!)
		""".unindent().cleanForFts());
	});

	///   ///   ///   ///   ///

	final Note noteWithFM = Note(
		'example/markdown/Note with Frontmatter.md',
		'''
		---
		title: I am r/verysmart
		tags: yes, sometimes
		---

		## Subheading

		- [Very cool website](https://adamkiss.com)
		- [This workflow](https://github.com/adamkiss/alfred-noteplan)
		- [The Witcher is a book you should read](https://en.wikipedia.org/wiki/The_Witcher)

		## These are ignored
		- [Link to a note with custom title]([[A cool note]])
		- [file](Note_attachmends/Amazing File.mp4)

		## Shop for these

		* Cookies
		* Bread
		* Don't forget to pick up milk (!)
		'''.unindent(),
		DateTime.now().millisecondsSinceEpoch,
		1
	);

	test("Note with a frontmatter", () {
		expect(noteWithFM.title, "I am r/verysmart");
		expect(noteWithFM.code_bits.isEmpty, true);
		expect(noteWithFM.hyperlinks.isNotEmpty, true);

		expect(noteWithFM.hyperlinks.length, 3);
		expect(noteWithFM.hyperlinks[0].url, 'https://adamkiss.com');
		expect(noteWithFM.hyperlinks[0].title, 'Very cool website');
		expect(noteWithFM.hyperlinks[0].description, null);

		expect(noteWithFM.hyperlinks[1].url, 'https://github.com/adamkiss/alfred-noteplan');
		expect(noteWithFM.hyperlinks[1].title, 'This workflow');
		expect(noteWithFM.hyperlinks[1].description, null);

		expect(noteWithFM.hyperlinks[2].url, 'https://en.wikipedia.org/wiki/The_Witcher');
		expect(noteWithFM.hyperlinks[2].title, 'The Witcher is a book you should read');
		expect(noteWithFM.hyperlinks[2].description, null);
	});

	///   ///   ///   ///   ///

	final Note noteWithCode = Note(
		'example/markdown/Note with quite a bit of code.md',
		'''
		---
		title: I was writing these all night
		---

		## Something without title or language (ignored)

		```
		<?php

		app()->route('/hyperlinks/(:any)', fn(string \$id) => new Route(\$id));
		```

		## Language only (ignored)

		```js
		document.addEventListener('click', () => console.log('Arrow fns are cool!'));
		```

		## This time with title

		```dart (Enum of my stupidity)
		Enum AlfredNoteplan2 {
			javascript,
			php,
			dart;
		}
		```

		## I was talkative this time

		```swift (I still don't understand - And people call it "elegant"?)
		@_functionBuilder
		struct NodeBuilder {
			static func buildBlock<Value>(_ children: Node<Value>...) -> [Node<Value>] {
				children
			}
		}
		```

		'''.unindent(),
		DateTime.now().millisecondsSinceEpoch,
		1
	);

	test("Note with a lot of code", () {
		expect(noteWithCode.title, "I was writing these all night");
		expect(noteWithCode.hyperlinks.isEmpty, true);
		expect(noteWithCode.code_bits.isNotEmpty, true);

		expect(noteWithCode.code_bits.length, 2);
		expect(noteWithCode.code_bits[0].language, 'dart');
		expect(noteWithCode.code_bits[0].title, 'Enum of my stupidity');
		expect(noteWithCode.code_bits[1].language, 'swift');
		expect(noteWithCode.code_bits[1].title, 'I still don\'t understand - And people call it "elegant"?');
	});
}