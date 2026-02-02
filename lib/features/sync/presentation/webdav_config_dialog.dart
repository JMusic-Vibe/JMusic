import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/sync/data/sync_config_repository.dart';
import 'package:jmusic/features/sync/domain/entities/sync_config.dart';
import 'package:jmusic/l10n/app_localizations.dart';

class WebdavConfigDialog extends ConsumerStatefulWidget {
  final SyncConfig? config;
  const WebdavConfigDialog({super.key, this.config});

  @override
  ConsumerState<WebdavConfigDialog> createState() => _WebdavConfigDialogState();
}

class _WebdavConfigDialogState extends ConsumerState<WebdavConfigDialog> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _pathController;
  
  bool _isObscure = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config?.name ?? 'My WebDAV');
    _urlController = TextEditingController(text: widget.config?.url ?? '');
    _userController = TextEditingController(text: widget.config?.username ?? '');
    _passwordController = TextEditingController(text: widget.config?.password ?? '');
    _pathController = TextEditingController(text: widget.config?.path ?? '/');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_urlController.text.isEmpty) return;
    
    setState(() => _saving = true);
    try {
      final repo = ref.read(syncConfigRepositoryProvider);
      
      final config = widget.config ?? SyncConfig();
      config.name = _nameController.text.trim();
      config.type = SyncType.webdav;
      config.url = _urlController.text.trim();
      config.username = _userController.text.trim();
      config.password = _passwordController.text;
      config.path = _pathController.text.trim();
      if (config.path!.isEmpty) config.path = '/';
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
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.config == null ? l10n.addSyncAccount : l10n.edit,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Account Name
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.accountName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
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
                    // URL
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'URL',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'https://example.com/webdav',
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
                    // Path
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.musicFolderPath,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
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
                    // Username
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
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
                    // Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.password,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
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
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(l10n.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

