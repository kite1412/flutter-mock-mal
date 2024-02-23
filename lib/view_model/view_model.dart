import 'package:flutter/cupertino.dart';

// Base class for ViewModel
class ViewModel extends ChangeNotifier {
  void setState(VoidCallback set) {
    set();
    notifyListeners();
  }
}

// InheritedNotifier of ViewModel's subclasses
class ViewModelNotifier<T extends ViewModel> extends InheritedNotifier<T> {
  const ViewModelNotifier({
    super.key,
    required super.notifier,
    required super.child
  });

  static ViewModelNotifier<VM>? maybeOf<VM extends ViewModel>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ViewModelNotifier<VM>>();

  // this could throw an error if no ViewModelNotifier in the tree, use maybeOf instead for safety.
  static ViewModelNotifier<VM> of<VM extends ViewModel>(BuildContext context) => maybeOf<VM>(context)!;

  // return the viewModel.
  static VM viewModel<VM extends ViewModel>(BuildContext context) => of<VM>(context).notifier!;
}

// builder with ViewModel instance.
typedef ViewModelBuilder<VM extends ViewModel> = Widget Function(VM);

// widget that provide a viewModel to its child, use this as the direct parent
// of widgets that asking for a ViewModel.
class ViewModelProvider<T extends ViewModel> extends StatelessWidget {
  final T viewModel;
  final ViewModelBuilder<T> builder;

  const ViewModelProvider({
    super.key,
    required this.viewModel,
    required this.builder
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelNotifier(
      notifier: viewModel,
      child: Builder(builder: (innerContext) => this.builder(
        ViewModelNotifier.viewModel<T>(innerContext)
      ))
    );
  }
}