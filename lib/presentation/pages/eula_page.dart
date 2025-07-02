import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:emi_manager/logic/eula_provider.dart';

class EulaPage extends StatefulWidget {
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;
  const EulaPage({Key? key, required this.onAccepted, required this.onDeclined}) : super(key: key);

  @override
  State<EulaPage> createState() => _EulaPageState();
}

class _EulaPageState extends State<EulaPage> {
  String? _eulaText;
  String? _eulaVersion;
  bool _loading = true;
  bool _error = false;
  bool _hasRead = false;

  @override
  void initState() {
    super.initState();
    _fetchEula();
  }

  Future<void> _fetchEula() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final activeEula = await EulaProvider.getActiveEula();
      if (activeEula != null) {
        setState(() {
          _eulaText = activeEula['agreement_text'] ?? '';
          _eulaVersion = activeEula['version']?.toString() ?? '';
          _loading = false;
        });
      } else {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _acceptEula() async {
    await EulaProvider.acceptEula(_eulaVersion);
    widget.onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load EULA.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchEula,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'End User License Agreement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false, // No back button
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_eulaVersion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Version: $_eulaVersion', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                SizedBox(height: 8),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Markdown(
                        data: _eulaText ?? '',
                        styleSheet: MarkdownStyleSheet(
                          p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                          h1: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          h2: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          listIndent: 24.0,
                          blockquote: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          blockquotePadding: const EdgeInsets.only(left: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _hasRead,
                      onChanged: (val) {
                        setState(() {
                          _hasRead = val ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _hasRead = !_hasRead;
                          });
                        },
                        child: Text(
                          'I have read the entire terms and conditions',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _hasRead ? _acceptEula : null,
                      child: Text('Accept'),
                    ),
                    OutlinedButton(
                      onPressed: widget.onDeclined,
                      child: Text('Decline'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
