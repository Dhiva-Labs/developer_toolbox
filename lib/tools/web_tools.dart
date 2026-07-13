import 'package:flutter/material.dart';

import '../widgets/tool_widgets.dart';

// ---------------------------------------------------------------------------
// Regex Tester
// ---------------------------------------------------------------------------

class RegexTesterTool extends StatefulWidget {
  const RegexTesterTool({super.key});

  @override
  State<RegexTesterTool> createState() => _RegexTesterToolState();
}

class _RegexTesterToolState extends State<RegexTesterTool> {
  final _pattern = TextEditingController();
  final _text = TextEditingController();
  bool _caseSensitive = true;
  bool _multiLine = false;
  bool _dotAll = false;
  String? _error;
  List<RegExpMatch> _matches = [];

  void _run() {
    setState(() {
      _error = null;
      _matches = [];
      if (_pattern.text.isEmpty) return;
      try {
        final re = RegExp(
          _pattern.text,
          caseSensitive: _caseSensitive,
          multiLine: _multiLine,
          dotAll: _dotAll,
        );
        _matches = re.allMatches(_text.text).toList();
      } on FormatException catch (e) {
        _error = e.message;
      }
    });
  }

  /// Test text with matches highlighted.
  Widget _highlighted(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_matches.isEmpty) {
      return Text(_text.text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14));
    }
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final m in _matches) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: _text.text.substring(cursor, m.start)));
      }
      spans.add(TextSpan(
        text: _text.text.substring(m.start, m.end),
        style: TextStyle(
          backgroundColor: scheme.primaryContainer,
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ));
      cursor = m.end;
    }
    if (cursor < _text.text.length) {
      spans.add(TextSpan(text: _text.text.substring(cursor)));
    }
    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: 'Regex Tester',
      children: [
        TextField(
          controller: _pattern,
          onChanged: (_) => _run(),
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: const InputDecoration(
            labelText: 'Pattern',
            prefixText: '/',
            border: OutlineInputBorder(),
          ),
        ),
        Wrap(
          spacing: 4,
          children: [
            FilterChip(
              label: const Text('Case sensitive'),
              selected: _caseSensitive,
              onSelected: (v) {
                _caseSensitive = v;
                _run();
              },
            ),
            FilterChip(
              label: const Text('Multiline (^\$ per line)'),
              selected: _multiLine,
              onSelected: (v) {
                _multiLine = v;
                _run();
              },
            ),
            FilterChip(
              label: const Text('Dot matches newline'),
              selected: _dotAll,
              onSelected: (v) {
                _dotAll = v;
                _run();
              },
            ),
          ],
        ),
        ToolInput(
          controller: _text,
          label: 'Test text',
          hint: 'Text to match against…',
          onChanged: (_) => _run(),
        ),
        if (_error != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(_error!),
            ),
          )
        else ...[
          Text(
            _matches.isEmpty && _pattern.text.isNotEmpty
                ? 'No matches'
                : '${_matches.length} match${_matches.length == 1 ? '' : 'es'}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _highlighted(context),
          ),
          for (final (i, m) in _matches.indexed.take(100))
            Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                dense: true,
                leading: Text('#${i + 1}'),
                title: SelectableText(
                  m.group(0) ?? '',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                subtitle: Text(
                  'index ${m.start}–${m.end}'
                  '${m.groupCount > 0 ? '  •  groups: ${[
                      for (var g = 1; g <= m.groupCount; g++) m.group(g)
                    ].join(', ')}' : ''}',
                ),
              ),
            ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HTTP Status Codes
// ---------------------------------------------------------------------------

class _StatusCode {
  const _StatusCode(this.code, this.name, this.description);
  final int code;
  final String name;
  final String description;
}

const _statusCodes = <_StatusCode>[
  _StatusCode(100, 'Continue', 'The server has received the request headers; the client should proceed to send the body.'),
  _StatusCode(101, 'Switching Protocols', 'The requester has asked the server to switch protocols (e.g. to WebSocket).'),
  _StatusCode(102, 'Processing', 'The server is processing the request but no response is available yet (WebDAV).'),
  _StatusCode(103, 'Early Hints', 'Preload hints sent before the final response.'),
  _StatusCode(200, 'OK', 'Standard successful response.'),
  _StatusCode(201, 'Created', 'The request succeeded and a new resource was created.'),
  _StatusCode(202, 'Accepted', 'The request was accepted for processing, but is not complete.'),
  _StatusCode(204, 'No Content', 'Success, but there is no body to return.'),
  _StatusCode(206, 'Partial Content', 'Partial resource delivered due to a Range header.'),
  _StatusCode(301, 'Moved Permanently', 'The resource has permanently moved to a new URL.'),
  _StatusCode(302, 'Found', 'Temporary redirect; the method may change to GET.'),
  _StatusCode(304, 'Not Modified', 'Cached version is still valid; no body returned.'),
  _StatusCode(307, 'Temporary Redirect', 'Temporary redirect that preserves the HTTP method.'),
  _StatusCode(308, 'Permanent Redirect', 'Permanent redirect that preserves the HTTP method.'),
  _StatusCode(400, 'Bad Request', 'The server cannot process the request due to a client error.'),
  _StatusCode(401, 'Unauthorized', 'Authentication is required or has failed.'),
  _StatusCode(403, 'Forbidden', 'The client is authenticated but not allowed to access the resource.'),
  _StatusCode(404, 'Not Found', 'The requested resource could not be found.'),
  _StatusCode(405, 'Method Not Allowed', 'The HTTP method is not supported by this resource.'),
  _StatusCode(408, 'Request Timeout', 'The server timed out waiting for the request.'),
  _StatusCode(409, 'Conflict', 'The request conflicts with the current state of the resource.'),
  _StatusCode(410, 'Gone', 'The resource is permanently gone; no forwarding address.'),
  _StatusCode(413, 'Payload Too Large', 'The request body exceeds server limits.'),
  _StatusCode(415, 'Unsupported Media Type', 'The request body format is not supported.'),
  _StatusCode(418, "I'm a Teapot", 'April Fools joke from RFC 2324; some servers use it as an easter egg.'),
  _StatusCode(422, 'Unprocessable Entity', 'The request is well-formed but semantically invalid.'),
  _StatusCode(429, 'Too Many Requests', 'The client has been rate limited.'),
  _StatusCode(500, 'Internal Server Error', 'A generic server-side failure.'),
  _StatusCode(501, 'Not Implemented', 'The server does not support the requested functionality.'),
  _StatusCode(502, 'Bad Gateway', 'An upstream server returned an invalid response.'),
  _StatusCode(503, 'Service Unavailable', 'The server is overloaded or down for maintenance.'),
  _StatusCode(504, 'Gateway Timeout', 'An upstream server did not respond in time.'),
];

class HttpStatusTool extends StatefulWidget {
  const HttpStatusTool({super.key});

  @override
  State<HttpStatusTool> createState() => _HttpStatusToolState();
}

class _HttpStatusToolState extends State<HttpStatusTool> {
  String _query = '';

  Color _classColor(int code) => switch (code ~/ 100) {
        1 => Colors.blueGrey,
        2 => Colors.green,
        3 => Colors.blue,
        4 => Colors.orange,
        _ => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final filtered = _statusCodes
        .where((s) =>
            q.isEmpty ||
            '${s.code}'.contains(q) ||
            s.name.toLowerCase().contains(q) ||
            s.description.toLowerCase().contains(q))
        .toList();

    return ToolPage(
      title: 'HTTP Status Codes',
      scrollable: false,
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search by code or name…',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final s = filtered[i];
              final color = _classColor(s.code);
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      '${s.code}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  title: Text('${s.code} ${s.name}'),
                  subtitle: Text(s.description),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// URL Parser
// ---------------------------------------------------------------------------

class UrlParserTool extends StatefulWidget {
  const UrlParserTool({super.key});

  @override
  State<UrlParserTool> createState() => _UrlParserToolState();
}

class _UrlParserToolState extends State<UrlParserTool> {
  final _input = TextEditingController();
  Uri? _uri;
  String? _error;

  void _parse(String value) {
    setState(() {
      _error = null;
      _uri = null;
      if (value.trim().isEmpty) return;
      try {
        _uri = Uri.parse(value.trim());
      } on FormatException catch (e) {
        _error = e.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uri = _uri;
    final rows = <(String, String)>[
      if (uri != null) ...[
        ('Scheme', uri.scheme),
        ('Host', uri.host),
        if (uri.hasPort) ('Port', '${uri.port}'),
        if (uri.userInfo.isNotEmpty) ('User info', uri.userInfo),
        ('Path', uri.path),
        if (uri.hasQuery) ('Query', uri.query),
        if (uri.fragment.isNotEmpty) ('Fragment', uri.fragment),
      ],
    ];

    return ToolPage(
      title: 'URL Parser',
      children: [
        ToolInput(
          controller: _input,
          label: 'URL',
          hint: 'https://user@example.com:8080/path?a=1&b=2#section',
          minLines: 2,
          maxLines: 4,
          onChanged: _parse,
        ),
        if (_error != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(_error!)),
          ),
        if (rows.isNotEmpty)
          Card(
            child: Column(
              children: [
                for (final (label, value) in rows)
                  ListTile(
                    dense: true,
                    title: Text(label),
                    subtitle: SelectableText(
                      value.isEmpty ? '(empty)' : value,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => copyToClipboard(context, value),
                    ),
                  ),
              ],
            ),
          ),
        if (uri != null && uri.queryParameters.isNotEmpty) ...[
          Text('Query parameters',
              style: Theme.of(context).textTheme.titleSmall),
          Card(
            child: Column(
              children: [
                for (final entry in uri.queryParametersAll.entries)
                  for (final value in entry.value)
                    ListTile(
                      dense: true,
                      title: Text(entry.key,
                          style: const TextStyle(fontFamily: 'monospace')),
                      subtitle: SelectableText(value,
                          style: const TextStyle(fontFamily: 'monospace')),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => copyToClipboard(context, value),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
