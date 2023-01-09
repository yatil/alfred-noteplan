import 'dart:convert';
import 'dart:io';

import 'package:alfred_noteplan_fts_refresh/about.dart';
import 'package:alfred_noteplan_fts_refresh/alfred.dart';
import 'package:alfred_noteplan_fts_refresh/config.dart';
import 'package:alfred_noteplan_fts_refresh/db_cache.dart';
import 'package:alfred_noteplan_fts_refresh/db_fts.dart';
import 'package:alfred_noteplan_fts_refresh/note_match.dart';
import 'package:alfred_noteplan_fts_refresh/refresh.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

bool _last_update_more_than(int last_update, {int compare = 10}) {
	return DateTime.now().millisecondsSinceEpoch > (last_update + compare);
}

String _usage = ''
	'Usage: noteplan_fts-[arch] [command] [arguments] \n'
	'Commands: \n'
	' - refresh <force?> - force is optional \n'
	' - debug \n'
	' - create <title> - required\n'
	' - date <query> - required, begins with ">"\n'
	' - search <query> - required\n'
;

void error(String err) {
	print(_usage);
	print('Error: ${err}');
	exit(1);
}

void main (List<String> arguments) {
	final int run_start = Config.ts();
	Config.init();

	if (arguments.isEmpty) {
		error('Command required.');
	}

	final String command = arguments.first;
	final String query = arguments.sublist(1).join(' ').trim();

	final db = DbFts(sqlite3.open(join(Config.workflow_root(), 'database.sqlite3')));
	db.ensure_setup();

	// Refresh & Exit
	if (command == 'refresh') {
		final int update_count = refresh(db, force: query == 'force');
		print('Updated ${update_count} items in ${Config.ts() - run_start}ms');
		exit(0);
	}

	// About
	if (command == 'debug') {
		final about = About();
		print(alf_to_results([
			alf_valid_item(
				'Workflow information', 'Copy to clipboard',
				arg: about.for_clipboard(),	variables: {'action':'copy-to-clipboard'}
			),
			alf_invalid_item(about.version, 'Workflow version', text: {'copy': about.version}),
			alf_invalid_item(about.sqlite_version, 'SQLite3 version', text: {'copy': about.sqlite_version}),
			alf_invalid_item(about.macos_version, 'macOS version', text: {'copy': about.macos_version}),
			alf_invalid_item(about.macos_arch, 'mac architecture', text: {'copy': about.macos_arch}),
		]));

		db.dispose();
		exit(0);
	}

	// From now on, we totally need query, so die if it's empty
	if (query.isEmpty) {
		error("Commands 'create', 'date' and 'search' require arguments.");
	}

	// Create new note
	if (command == 'create') {
		final cache = DbCache(sqlite3.open(Config.path_cache_db));
		print(cache.select_folders());

		cache.dispose();
		db.dispose();
		exit(0);
	}

	final int last_update = db.get_last_update();
	if (_last_update_more_than(last_update)) { refresh(db); }

	// Date parsing
	if (command == 'date') {
		final String? to_parse = RegExp(r'^>\s*(.*?)$').stringMatch(query);
		if (to_parse == null) {
			error("Commands 'date' expects argument in the form '><\\s>*?<query>");
		}
	}

	// Finally: Full-text search
	List<NoteMatch> found = db.search(query);
	print(alf_to_results(
		found
			.map((e) => e.to_alfred_result())
			.toList()
			..add(alf_create_item(query))
	));

	// DISPOSE
	db.dispose();
}