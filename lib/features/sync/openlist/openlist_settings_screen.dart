import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/widgets/capsule_toast.dart';
import 'package:jmusic/features/sync/openlist/openlist_service_manager.dart';
import 'package:jmusic/features/sync/openlist/openlist_webview_screen.dart';
import 'package:jmusic/l10n/app_localizations.dart';
import 'package:jmusic/core/services/preferences_service.dart';

class OpenListSettingsScreen extends ConsumerStatefulWidget {
  const OpenListSettingsScreen({super.key});

  @override
  ConsumerState<OpenListSettingsScreen> createState() => _OpenListSettingsScreenState();
}

class _OpenListSettingsScreenState extends ConsumerState<OpenListSettingsScreen> {
  String? _initialPassword;
  bool _loadingInitial = true;
  late TextEditingController _portCtrl;
  late TextEditingController _proxyHostCtrl;
  late TextEditingController _proxyPortCtrl;
  String _proxyMode = 'none';

  @override
  void initState() {
    super.initState();
    _loadInitialPassword();
    final prefs = ref.read(preferencesServiceProvider);
    _portCtrl = TextEditingController(text: prefs.openListPort.toString());
    _proxyMode = prefs.openListProxyMode;
    _proxyHostCtrl = TextEditingController(text: prefs.openListProxyHost);
    _proxyPortCtrl = TextEditingController(text: prefs.openListProxyPort.toString());
  }

  @override
  void dispose() {
    _portCtrl.dispose();
    _proxyHostCtrl.dispose();
    _proxyPortCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPassword() async {
    final manager = OpenListServiceManager(ref.read(preferencesServiceProvider));
    final pwd = await manager.getInitialAdminPassword();
    if (mounted) {
      setState(() {
        _initialPassword = pwd;
        _loadingInitial = false;
      });
    }
  }

  Future<void> _clearInitialPassword() async {
    final manager = OpenListServiceManager(ref.read(preferencesServiceProvider));
    await manager.clearInitialAdminPassword();
    if (mounted) {
      setState(() {
        _initialPassword = null;
      });
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.resetAdminPasswordTitle),
        // content: const Text('将生成一个新的随机密码并替换当前密码，是否继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.confirm)),
        ],
      ),
    );
    if (confirmed != true) return;

    final manager = OpenListServiceManager(ref.read(preferencesServiceProvider));
    final pwd = await manager.resetAdminPassword();
    if (!mounted) return;
    if (pwd == null || pwd.isEmpty) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l10n.resetFailed),
          content: Text(manager.lastError ?? l10n.unknownError),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.confirm)),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.newPasswordGenerated),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.usernameAdmin,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 20),
                  onPressed: () async {
                    await Clipboard.setData(const ClipboardData(text: 'admin'));
                    if (context.mounted) {
                      CapsuleToast.show(context, l10n.copyToClipboard);
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.newPassword(pwd),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, size: 20),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: pwd));
                    if (context.mounted) {
                      CapsuleToast.show(context, l10n.copyToClipboard);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.confirm)),
        ],
      ),
    );
  }

  Future<void> _showPortProxyDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final serviceState = ref.read(openListServiceControllerProvider);
    final canEditConfig = !serviceState.isRunning && !serviceState.isBusy;
    final prefs = ref.read(preferencesServiceProvider);

    final portCtrl = TextEditingController(text: _portCtrl.text);
    final proxyHostCtrl = TextEditingController(text: _proxyHostCtrl.text);
    final proxyPortCtrl = TextEditingController(text: _proxyPortCtrl.text);
    String proxyMode = _proxyMode;

    await showDialog<void>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(l10n.portAndProxy),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: portCtrl,
                  enabled: canEditConfig,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.port,
                    hintText: '5244',
                    helperText: canEditConfig ? l10n.stopServiceToModify : l10n.serviceRunningLocked,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                Text(l10n.proxySettings),
                RadioListTile<String>(
                  value: 'none',
                  groupValue: proxyMode,
                  onChanged: canEditConfig
                      ? (v) => setLocalState(() => proxyMode = v ?? 'none')
                      : null,
                  title: Text(l10n.noProxy),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  value: 'system',
                  groupValue: proxyMode,
                  onChanged: canEditConfig
                      ? (v) => setLocalState(() => proxyMode = v ?? 'system')
                      : null,
                  title: Text(l10n.systemProxy),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  value: 'custom',
                  groupValue: proxyMode,
                  onChanged: canEditConfig
                      ? (v) => setLocalState(() => proxyMode = v ?? 'custom')
                      : null,
                  title: Text(l10n.customProxy),
                  contentPadding: EdgeInsets.zero,
                ),
                if (proxyMode == 'custom') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: proxyHostCtrl,
                    enabled: canEditConfig,
                    decoration: InputDecoration(
                      labelText: l10n.ipAddress,
                      hintText: '127.0.0.1',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: proxyPortCtrl,
                    enabled: canEditConfig,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.port,
                      hintText: '7890',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.cancel)),
            TextButton(
              onPressed: canEditConfig
                  ? () async {
                    final port = int.tryParse(portCtrl.text.trim());
                    if (port == null || port <= 0 || port > 65535) {
                      CapsuleToast.show(context, l10n.invalidPort);
                      return;
                    }
                    final proxyPort = int.tryParse(proxyPortCtrl.text.trim()) ?? prefs.openListProxyPort;
                    if (proxyMode == 'custom') {
                      if (proxyHostCtrl.text.trim().isEmpty) {
                        CapsuleToast.show(context, l10n.proxyHostEmpty);
                        return;
                      }
                      if (proxyPort <= 0 || proxyPort > 65535) {
                        CapsuleToast.show(context, l10n.invalidProxyPort);
                        return;
                      }
                    }

                    await prefs.setOpenListPort(port);
                    await prefs.setOpenListProxyMode(proxyMode);
                    await prefs.setOpenListProxyHost(proxyHostCtrl.text.trim());
                    await prefs.setOpenListProxyPort(proxyPort);

                    final manager = OpenListServiceManager(ref.read(preferencesServiceProvider));
                    final ok = await manager.applyConfig(OpenListRuntimeConfig(
                      port: port,
                      proxyMode: proxyMode,
                      proxyHost: proxyHostCtrl.text.trim(),
                      proxyPort: proxyPort,
                    ));

                    if (!ok) {
                      CapsuleToast.show(context, manager.lastError ?? l10n.saveFailed);
                    } else {
                      _portCtrl.text = port.toString();
                      _proxyMode = proxyMode;
                      _proxyHostCtrl.text = proxyHostCtrl.text.trim();
                      _proxyPortCtrl.text = proxyPort.toString();
                      if (mounted) {
                        setState(() {});
                      }
                      CapsuleToast.show(context, l10n.savedRestartRequired);
                      await ref.read(openListServiceControllerProvider.notifier).refresh();
                      Navigator.pop(c);
                    }
                  }
                  : null,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serviceState = ref.watch(openListServiceControllerProvider);
    final serviceController = ref.read(openListServiceControllerProvider.notifier);
    final manageUrl = OpenListServiceManager.buildManageUrl(serviceState.address, serviceState.port);
    final supportsWebView = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.openlist),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        serviceState.isRunning ? Icons.cloud_done : Icons.cloud_off,
                        color: serviceState.isRunning
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.openListService,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      // IconButton(
                      //   tooltip: '默认用户名：admin',
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.info_outline),
                      // ),
                      if (serviceState.isBusy)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    serviceState.isRunning ? l10n.statusRunning : l10n.statusStopped,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.address(serviceState.address, serviceState.port.toString()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (serviceState.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      serviceState.error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: serviceState.isBusy
                            ? null
                            : () => serviceState.isRunning
                                ? serviceController.stop()
                                : serviceController.start(),
                        icon: Icon(serviceState.isRunning ? Icons.stop : Icons.play_arrow),
                        label: Text(serviceState.isRunning ? l10n.stop : l10n.start),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: l10n.refresh,
                        onPressed: () => serviceController.refresh(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.stopServiceExitHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.managementPage,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    serviceState.isRunning
                        ? l10n.accessManagementPage
                        : l10n.startServiceFirst,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: serviceState.isRunning && supportsWebView
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OpenListWebViewScreen(
                                      title: l10n.openListManagement,
                                      url: manageUrl,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.web),
                        label: Text(l10n.openInApp),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: serviceState.isRunning
                                  ? () => OpenListWebViewScreen.openExternal(manageUrl)
                                  : null,
                              icon: const Icon(Icons.open_in_new),
                              label: Text(l10n.openInBrowser),
                            ),
                          ),
                          // const SizedBox(width: 8),
                          // IconButton(
                          //   tooltip: '打开首页',
                          //   onPressed: serviceState.isRunning
                          //       ? () => OpenListWebViewScreen.openExternal(externalUrl)
                          //       : null,
                          //   icon: const Icon(Icons.home),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adminInfo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_loadingInitial)
                    const LinearProgressIndicator(minHeight: 2)
                  else if (_initialPassword != null && _initialPassword!.isNotEmpty) ...[
                    Text(
                      l10n.saveCredentials(_initialPassword!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _clearInitialPassword,
                        child: Text(l10n.saved),
                      ),
                    ),
                  ] else
                    Text(
                      l10n.defaultUsernameAdmin,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: serviceState.isBusy ? null : () => _resetPassword(context),
                    icon: const Icon(Icons.lock_reset),
                    label: Text(l10n.resetPassword),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              title: Text(l10n.portAndProxy),
              subtitle: Text(_proxyMode == 'none' ? l10n.noProxy : _proxyMode == 'system' ? l10n.systemProxy : l10n.customProxy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPortProxyDialog(context),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: SwitchListTile(
              title: Text(l10n.autoStartOpenListOnAppLaunch),
              // subtitle: Text(l10n.autoStartOpenListDescription),
              value: ref.watch(preferencesServiceProvider).openListAutoStart,
              onChanged: (value) async {
                await ref.read(preferencesServiceProvider).setOpenListAutoStart(value);
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.keepAliveTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.keepAliveDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final manager = OpenListServiceManager(ref.read(preferencesServiceProvider));
                            final ok = await manager.openAutoStartSettings();
                            if (ok) {
                              CapsuleToast.show(context, '已打开自启动设置，请允许应用自启动');
                            } else {
                              CapsuleToast.show(context, '无法打开自启动设置，请手动在系统设置中查找');
                            }
                          },
                          icon: const Icon(Icons.autorenew),
                          label: Text(l10n.openAutoStart),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
