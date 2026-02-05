import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class WebDavConfigScreen extends ConsumerStatefulWidget {
  final SyncConfig? config;
  final SyncType initialType;
  final String? initialUrl;
  final String? initialUsername;
  final String? initialPassword;
  const WebDavConfigScreen({
    super.key,
    this.config,
    this.initialType = SyncType.webdav,
    this.initialUrl,
    this.initialUsername,
    this.initialPassword,
  });

  @override
  ConsumerState<WebDavConfigScreen> createState() => _WebDavConfigScreenState();
}

class _WebDavConfigScreenState extends ConsumerState<WebDavConfigScreen> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _pathController;
  late TextEditingController _tokenController;

  bool _isObscure = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final isOpenList = (widget.config?.type ?? widget.initialType) == SyncType.openlist;
    _nameController = TextEditingController(text: widget.config?.name ?? (isOpenList ? 'My OpenList' : 'My WebDAV'));
    _urlController = TextEditingController(text: widget.config?.url ?? (widget.initialUrl ?? ''));
    _userController = TextEditingController(text: widget.config?.username ?? (widget.initialUsername ?? ''));
    _passwordController = TextEditingController(text: widget.config?.password ?? (widget.initialPassword ?? ''));
    _pathController = TextEditingController(text: widget.config?.path ?? '/');
    _tokenController = TextEditingController(text: widget.config?.token ?? '');
  }

  String _normalizeUrl(String input) {
    final value = input.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return 'http://$value';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _pathController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_urlController.text.isEmpty) return;
    final isOpenList = (widget.config?.type ?? widget.initialType) == SyncType.openlist;

    setState(() => _saving = true);
    try {
      final repo = ref.read(syncConfigRepositoryProvider);

      final config = widget.config ?? SyncConfig();
      config.name = _nameController.text.trim();
      config.type = widget.config?.type ?? widget.initialType;
      config.url = _normalizeUrl(_urlController.text);
      config.username = _userController.text.trim();
      config.password = _passwordController.text;
      config.path = _pathController.text.trim();
      if (config.path!.isEmpty) config.path = '/';
      config.token = isOpenList ? _tokenController.text.trim() : null;
      config.isEnabled = true;

      await repo.saveConfig(config);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CapsuleToast.show(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isOpenList = (widget.config?.type ?? widget.initialType) == SyncType.openlist;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.config == null ? l10n.addSyncAccount : l10n.edit,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Text(
                  l10n.save,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.accountName,
                prefixIcon: Icon(
                  Icons.label,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'URL',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: isOpenList ? 'http://127.0.0.1:5244/dav' : 'http://example.com:80/webdav',
                prefixIcon: Icon(
                  Icons.link,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: l10n.webdavUrlLabel,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'URL',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        content: Text(
                          l10n.webdavUrlLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.confirm),
                          )
                        ],
                      ),
                    );
                  },
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.musicFolderPath,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pathController,
              decoration: InputDecoration(
                hintText: '/music',
                prefixIcon: Icon(
                  Icons.folder,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: l10n.identificationRules,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          l10n.identificationRules,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        content: Text(
                          '1. Artist/Album/Song.mp3\n'
                          '2. Artist - Album - Song.mp3\n\n'
                          '${l10n.rulesTooltip}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.confirm),
                          )
                        ],
                      ),
                    );
                  },
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.username,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userController,
              decoration: InputDecoration(
                hintText: l10n.username,
                prefixIcon: Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.password,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: l10n.password,
                prefixIcon: Icon(
                  Icons.password,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            if (isOpenList) ...[
              Text(
                'Token',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  hintText: 'Token (optional)',
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

