import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'settings_providers.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class ProxyConfigDialog extends ConsumerStatefulWidget {
  const ProxyConfigDialog({super.key});

  @override
  ConsumerState<ProxyConfigDialog> createState() => _ProxyConfigDialogState();
}

class _ProxyConfigDialogState extends ConsumerState<ProxyConfigDialog> {
  late TextEditingController _hostCtrl;
  late TextEditingController _portCtrl;
  String _mode = 'system';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(proxySettingsProvider);
    _mode = settings.mode;
    _hostCtrl = TextEditingController(text: settings.host);
    _portCtrl = TextEditingController(text: settings.port.toString());
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(proxySettingsProvider.notifier);
    await notifier.setMode(_mode);
    if (_mode == 'custom') {
      await notifier.setHost(_hostCtrl.text);
      await notifier.setPort(int.tryParse(_portCtrl.text) ?? 7890);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proxySettings),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.systemProxy),
                  value: 'system',
                  groupValue: _mode,
                  onChanged: (v) => setState(() => _mode = v!),
                ),
                RadioListTile<String>(
                  title: Text(l10n.noProxy),
                  value: 'none',
                  groupValue: _mode,
                  onChanged: (v) => setState(() => _mode = v!),
                ),
                RadioListTile<String>(
                  title: Text(l10n.customProxy),
                  value: 'custom',
                  groupValue: _mode,
                  onChanged: (v) => setState(() => _mode = v!),
                ),
                if (_mode == 'custom') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _hostCtrl,
                            decoration: InputDecoration(
                              labelText: l10n.ipAddress,
                              hintText: '127.0.0.1',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _portCtrl,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: l10n.port,
                              hintText: '7890',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

