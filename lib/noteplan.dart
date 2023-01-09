String _create_noteplan_url({
	String method = 'addNote',
	Map<String, dynamic>? params
}) {
	final url = Uri(
		scheme: 'noteplan',
		host: 'x-callback-url',
		path: method,
		queryParameters: params
	);
	return url.toString();
}

String calendar_url(String bname, {bool sameWindow = true}) {
	return _create_noteplan_url(params: {
		'noteDate': bname,
		'useExistingSubWindow': sameWindow ? 'yes' : 'no'
	});
}

String note_url(String filename, {bool sameWindow = true}) {
	return _create_noteplan_url(params: {
		'filename': filename,
		'useExistingSubWindow': sameWindow ? 'yes' : 'no'
	});
}

String create_url(
	String folder,
	String body,
	{bool sameWindow = true}
) => _create_noteplan_url(
	method: 'addNote',
	params: {
		'text': body,
		'folder': folder,
		'useExistingSubWindow': sameWindow ? 'yes' : 'no',
		'openNote': 'yes'
	}
);
