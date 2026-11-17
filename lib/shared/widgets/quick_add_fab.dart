import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/vehicles/providers.dart';
import '../quick_add_navigation.dart';

/// Señal para cerrar el menú rápido al cambiar de pestaña.
///
/// Las ramas de las pestañas conservan su estado y desactivan sus tickers, así
/// que el cierre no puede depender de una animación: se hace al instante.
final quickAddCloseSignalProvider = StateProvider<int>((ref) => 0);

/// FAB con las acciones de registro rápido: mantenimiento, tanqueada y gasto.
///
/// Se muestra solo con vehículos registrados. Al abrirse atenúa el contenido
/// con un scrim, rota el «+» a «×» y despliega las acciones de abajo hacia
/// arriba. Sin [onSelected], cada acción navega al formulario correspondiente.
class QuickAddFab extends ConsumerStatefulWidget {
  const QuickAddFab({super.key, this.onSelected});

  /// Permite sustituir la navegación por defecto (pruebas o flujos propios).
  final ValueChanged<QuickAddAction>? onSelected;

  @override
  ConsumerState<QuickAddFab> createState() => _QuickAddFabState();
}

class _QuickAddFabState extends ConsumerState<QuickAddFab>
    with SingleTickerProviderStateMixin {
  static const _openDuration = Duration(milliseconds: 240);
  static const _closeDuration = Duration(milliseconds: 180);

  final _portal = OverlayPortalController();
  final _link = LayerLink();
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: _openDuration,
    reverseDuration: _closeDuration,
  );

  bool _isOpen = false;

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    setState(() => _isOpen = true);
    _portal.show();
    _animation.forward();
  }

  Future<void> _close({bool instant = false}) async {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    if (instant) {
      _animation.value = 0;
      _portal.hide();
      return;
    }
    await _animation.reverse();
    if (mounted) _portal.hide();
  }

  void _select(QuickAddAction action) {
    if (!_isOpen) return;
    // Elegir una acción navega de inmediato: el menú se retira sin animación
    // de salida para no retrasar el formulario.
    setState(() => _isOpen = false);
    _animation.value = 0;
    _portal.hide();

    final onSelected = widget.onSelected;
    if (onSelected != null) {
      onSelected(action);
    } else {
      startQuickAdd(context, ref, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? const [];
    // Sin vehículos la vista ya ofrece crearlo.
    if (vehicles.isEmpty) return const SizedBox.shrink();

    // Al cambiar de pestaña la rama pierde sus tickers: se cierra al instante.
    ref.listen<int>(
      quickAddCloseSignalProvider,
      (_, _) => _close(instant: true),
    );

    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    _animation.duration = disableAnimations ? Duration.zero : _openDuration;
    _animation.reverseDuration = disableAnimations
        ? Duration.zero
        : _closeDuration;

    return PopScope(
      canPop: !_isOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: CompositedTransformTarget(
          link: _link,
          child: FloatingActionButton(
            heroTag: null,
            tooltip: _isOpen ? 'Cerrar' : 'Registrar',
            onPressed: _toggle,
            child: RotationTransition(
              turns: Tween<double>(begin: 0, end: 0.125).animate(
                CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _close},
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animation,
                  curve: Curves.easeOut,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: ColoredBox(
                    color: theme.colorScheme.scrim.withValues(alpha: 0.32),
                  ),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.topRight,
              followerAnchor: Alignment.bottomRight,
              offset: const Offset(0, -AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width - AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (
                      var index = 0;
                      index < QuickAddAction.values.length;
                      index++
                    )
                      Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : AppSpacing.sm,
                        ),
                        child: _QuickAddActionButton(
                          action: QuickAddAction.values[index],
                          animation: CurvedAnimation(
                            parent: _animation,
                            curve: Interval(
                              (QuickAddAction.values.length - 1 - index) * 0.16,
                              1,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          onTap: () => _select(QuickAddAction.values[index]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddActionButton extends StatelessWidget {
  const _QuickAddActionButton({
    required this.action,
    required this.animation,
    required this.onTap,
  });

  final QuickAddAction action;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, AppSpacing.md * (1 - value)),
            child: Transform.scale(
              scale: 0.85 + 0.15 * value,
              alignment: Alignment.bottomRight,
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: AppRadii.pillAll,
        elevation: 2,
        shadowColor: scheme.shadow.withValues(alpha: 0.24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.pillAll,
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: action.semanticLabel,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(action.icon, size: 20, color: scheme.primary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
