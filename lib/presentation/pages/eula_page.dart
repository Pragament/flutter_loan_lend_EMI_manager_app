import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:emi_manager/logic/eula_provider.dart';
import 'package:emi_manager/presentation/l10n/app_localizations.dart';

class EulaPage extends StatefulWidget {
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;

  final String languageCode;
  final bool showAppBar;
  const EulaPage(
      {Key? key,
      required this.onAccepted,
      required this.onDeclined,
      this.languageCode = 'en',
      this.showAppBar = true})
      : super(key: key);

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
      final activeEula = await EulaProvider.getActiveEula(widget.languageCode);

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

    final localizations = AppLocalizations.of(context)!;

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
              Text(localizations.eulaLoadError),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchEula,
                child: Text(localizations.eulaRetry),
              ),
            ],
          ),
        ),
      );
    }
    final cardHeight = MediaQuery.of(context).size.height * 0.35;
    final cardMinHeight = 550.0;
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(
                  localizations.eulaTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 24,
                  ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false, // No back button
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (_eulaVersion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('${localizations.eulaVersion}: $_eulaVersion',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                SizedBox(height: 8),
                SizedBox(
                  height:
                      cardHeight < cardMinHeight ? cardMinHeight : cardHeight,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                            color: theme.textTheme.bodyLarge?.color
                                ?.withOpacity(0.8),
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

                // The following actions can be placed above the onboarding dots
                SizedBox(height: 10),
                EulaActions(
                  hasRead: _hasRead,
                  onHasReadChanged: (val) {
                    setState(() {
                      _hasRead = val ?? false;
                    });
                  },
                  onAccept: _hasRead ? _acceptEula : null,
                  onDecline: widget.onDeclined,
                  localizations: localizations,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EulaActions extends StatelessWidget {
  final bool hasRead;
  final ValueChanged<bool?> onHasReadChanged;
  final VoidCallback? onAccept;
  final VoidCallback onDecline;
  final AppLocalizations localizations;
  final ThemeData theme;
  const EulaActions({
    Key? key,
    required this.hasRead,
    required this.onHasReadChanged,
    required this.onAccept,
    required this.onDecline,
    required this.localizations,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: hasRead,
              onChanged: onHasReadChanged,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onHasReadChanged(!hasRead),
                child: Text(
                  localizations.eulaAgree,
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
              onPressed: onAccept,
              child: Text(localizations.eulaAccept),
            ),
            OutlinedButton(
              onPressed: onDecline,
              child: Text(localizations.eulaDecline),
            ),
          ],
        ),
      ],
    );
  }
}
