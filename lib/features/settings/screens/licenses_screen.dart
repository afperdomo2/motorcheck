import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_info.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/loading_indicator.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Licencias')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppInfo.name} · v${AppInfo.version}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '© ${AppInfo.copyrightYear} ${AppInfo.copyrightHolder}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppInfo.licenseName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Puedes leer, compilar y usar esta app para fines '
                    'personales o educativos. La venta y cualquier uso '
                    'comercial están prohibidos.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SelectionArea(
                    child: Text(
                      AppInfo.licenseUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Terceros', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const ExpansionTile(
                  leading: _TonalIcon(icon: Icons.font_download_outlined),
                  title: Text('Fuentes Barlow'),
                  subtitle: Text('SIL Open Font License 1.1'),
                  childrenPadding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  children: [_FontLicenseText()],
                ),
                const Divider(indent: 72),
                ListTile(
                  leading: const _TonalIcon(icon: Icons.article_outlined),
                  title: const Text('Licencias de paquetes'),
                  subtitle: const Text('Dependencias de Flutter y Dart'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppInfo.name,
                    applicationVersion: 'v${AppInfo.version}',
                    applicationLegalese:
                        '© ${AppInfo.copyrightYear} '
                        '${AppInfo.copyrightHolder}\n'
                        '${AppInfo.licenseName}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'El texto completo de la licencia de esta aplicación está en el '
            'archivo LICENSE del repositorio.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _FontLicenseText extends StatefulWidget {
  const _FontLicenseText();

  @override
  State<_FontLicenseText> createState() => _FontLicenseTextState();
}

class _FontLicenseTextState extends State<_FontLicenseText> {
  late final Future<String> _license = rootBundle.loadString(
    AppInfo.fontLicenseAsset,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: _license,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'No se pudo cargar el texto de la licencia de las fuentes.',
              style: theme.textTheme.bodySmall,
            ),
          );
        }

        final text = snapshot.data;
        if (text == null) {
          return const SizedBox(height: 64, child: LoadingIndicator());
        }

        return SelectionArea(
          child: Text(text, style: theme.textTheme.bodySmall),
        );
      },
    );
  }
}

class _TonalIcon extends StatelessWidget {
  final IconData icon;

  const _TonalIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
    );
  }
}
